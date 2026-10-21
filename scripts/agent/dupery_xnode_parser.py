"""Binary parser and decoder for Dupery XNode graphs, nodes, and port connections.

Decodes Unity-serialized XNode graphs (StoryNodeGraph, RoleSetsGraph) and individual
Node instances with their custom NodePortDictionary structures without reliance on
unsupported custom dictionary TypeTree unpacking.
"""

from __future__ import annotations

import struct
from typing import Any, Dict, List, Optional, Tuple


class XNodeBinaryReader:
    """Stream reader for little-endian Unity serialized binary objects."""

    def __init__(self, data: bytes, offset: int = 0) -> None:
        self.data = data
        self.offset = offset
        self.length = len(data)

    def can_read(self, size: int) -> bool:
        """Check if buffer has at least size bytes remaining."""
        return self.offset + size <= self.length

    def read_int(self) -> int:
        """Read 4-byte signed integer."""
        if not self.can_read(4):
            return 0
        val = struct.unpack_from("<i", self.data, self.offset)[0]
        self.offset += 4
        return val

    def read_uint(self) -> int:
        """Read 4-byte unsigned integer."""
        if not self.can_read(4):
            return 0
        val = struct.unpack_from("<I", self.data, self.offset)[0]
        self.offset += 4
        return val

    def read_long(self) -> int:
        """Read 8-byte signed integer."""
        if not self.can_read(8):
            return 0
        val = struct.unpack_from("<q", self.data, self.offset)[0]
        self.offset += 8
        return val

    def read_float(self) -> float:
        """Read 4-byte IEEE 754 float."""
        if not self.can_read(4):
            return 0.0
        val = struct.unpack_from("<f", self.data, self.offset)[0]
        self.offset += 4
        return val

    def read_pptr(self) -> Tuple[int, int]:
        """Read Unity PPtr (4-byte FileID + 8-byte PathID)."""
        file_id = self.read_int()
        path_id = self.read_long()
        return file_id, path_id

    def read_string(self) -> str:
        """Read length-prefixed UTF-8 string with 4-byte alignment padding."""
        length = self.read_uint()
        if length == 0 or not self.can_read(length):
            return ""
        raw_str = self.data[self.offset : self.offset + length]
        self.offset += length
        pad = (4 - (length % 4)) % 4
        self.offset += pad
        return raw_str.decode("utf-8", errors="replace")


def parse_xnode_binary(raw_bytes: bytes) -> Optional[Dict[str, Any]]:
    """Decode raw bytes of an XNode MonoBehaviour instance.

    Reconstructs node identity, parent graph PPtr, position Vector2, and all
    input/output ports with their inter-node connection links.
    """
    if len(raw_bytes) < 48:
        return None

    reader = XNodeBinaryReader(raw_bytes)

    # Base MonoBehaviour head: m_GameObject (12B), m_Enabled (4B), m_Script (12B)
    reader.read_pptr()
    _enabled = reader.read_uint()
    reader.read_pptr()
    node_name = reader.read_string()

    # XNode.Node fields: graph PPtr (12B), position Vector2 (8B)
    _graph_file_id, graph_path_id = reader.read_pptr()
    pos_x = reader.read_float()
    pos_y = reader.read_float()

    # NodePortDictionary.keys: List<string>
    key_count = reader.read_uint()
    if key_count > 100:
        return None
    keys = [reader.read_string() for _ in range(key_count)]

    # NodePortDictionary.values: List<NodePort>
    val_count = reader.read_uint()
    ports: List[Dict[str, Any]] = []

    for _ in range(val_count):
        field_name = reader.read_string()
        _owner_fid, owner_pid = reader.read_pptr()
        type_name = reader.read_string()

        # Port connections: List<PortConnection>
        conn_count = reader.read_uint()
        connections: List[Dict[str, Any]] = []
        for _ in range(conn_count):
            c_field = reader.read_string()
            _c_fid, target_node_id = reader.read_pptr()
            reroute_count = reader.read_uint()
            reroute_points: List[List[float]] = []
            for _ in range(reroute_count):
                rx = reader.read_float()
                ry = reader.read_float()
                reroute_points.append([round(rx, 2), round(ry, 2)])

            connections.append({
                "target_node": target_node_id,
                "target_port": c_field,
                "reroute_points": reroute_points,
            })

        direction = reader.read_int()
        _conn_type = reader.read_int()
        _type_constraint = reader.read_int()
        _is_dynamic = reader.read_uint()

        ports.append({
            "field_name": field_name,
            "direction": "output" if direction == 1 else "input",
            "type": type_name.split(",")[0] if type_name else "",
            "connections": connections,
        })

    return {
        "name": node_name,
        "graph_id": graph_path_id,
        "position": [round(pos_x, 2), round(pos_y, 2)],
        "keys": keys,
        "ports": ports,
    }
