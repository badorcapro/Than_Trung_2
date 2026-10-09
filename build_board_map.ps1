Add-Type -AssemblyName System.Drawing

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$elemDir = Join-Path $baseDir "Than_Tham_Nua_Voi_Godot\assets\maps\elements"

$width = 1424
$height = 2000
$bmp = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)

# 1. Warm Antique Parchment Background
$ptTop = New-Object System.Drawing.Point(0, 0)
$ptBottom = New-Object System.Drawing.Point(0, $height)
$colTop = [System.Drawing.Color]::FromArgb(246, 240, 226)
$colBottom = [System.Drawing.Color]::FromArgb(232, 218, 192)
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($ptTop, $ptBottom, $colTop, $colBottom)
$g.FillRectangle($bgBrush, 0, 0, $width, $height)
$bgBrush.Dispose()

# Vignette edges
$cornerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, 120, 80, 40))
$g.FillRectangle($cornerBrush, 0, 0, $width, 50)
$g.FillRectangle($cornerBrush, 0, ($height - 50), $width, 50)
$g.FillRectangle($cornerBrush, 0, 0, 50, $height)
$g.FillRectangle($cornerBrush, ($width - 50), 0, 50, $height)
$cornerBrush.Dispose()

# Outer double antique border
$borderCol1 = [System.Drawing.Color]::FromArgb(220, 100, 70, 35)
$borderPen1 = New-Object System.Drawing.Pen($borderCol1, 10.0)
$g.DrawRectangle($borderPen1, 20, 20, ($width - 40), ($height - 40))
$borderPen1.Dispose()

$borderCol2 = [System.Drawing.Color]::FromArgb(180, 195, 150, 70)
$borderPen2 = New-Object System.Drawing.Pen($borderCol2, 3.0)
$g.DrawRectangle($borderPen2, 34, 34, ($width - 68), ($height - 68))
$borderPen2.Dispose()

# 2. Southern Moat / River (Lotus Moat)
$ptR1 = New-Object System.Drawing.Point(0, 1720)
$ptR2 = New-Object System.Drawing.Point(0, 1964)
$colR1 = [System.Drawing.Color]::FromArgb(210, 120, 155, 150)
$colR2 = [System.Drawing.Color]::FromArgb(240, 85, 125, 120)
$riverBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($ptR1, $ptR2, $colR1, $colR2)
$g.FillRectangle($riverBrush, 36, 1720, ($width - 72), 244)
$riverBrush.Dispose()

# Waves
$wavePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(80, 255, 255, 255), 2.0)
for ($wy = 1750; $wy -lt 1950; $wy += 35) {
    for ($wx = 60; $wx -lt ($width - 80); $wx += 120) {
        $g.DrawArc($wavePen, $wx, $wy, 70, 20, 180, 180)
    }
}
$wavePen.Dispose()

# 3. South Fortress Wall & Gate Silhouette
$gatePath = "$elemDir\silhouette_gate_clean.png"
if (Test-Path $gatePath) {
    $gateImg = [System.Drawing.Bitmap]::FromFile($gatePath)
    $gateW = 540
    $gateH = 240
    $gateX = [int](($width - $gateW) / 2)
    $g.DrawImage($gateImg, $gateX, 1620, $gateW, $gateH)
    $gateImg.Dispose()
}

# Maiden Court Pagoda Silhouette above Huyen Spawn
$maidenPath = "$elemDir\silhouette_maiden_clean.png"
if (Test-Path $maidenPath) {
    $maidenImg = [System.Drawing.Bitmap]::FromFile($maidenPath)
    $g.DrawImage($maidenImg, (712 - 90), 80, 180, 105)
    $maidenImg.Dispose()
}

# 5. House Pavilion Drawing Helper
$titleFont = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center

function Draw-House-Pavilion($cx, $cy, $medallionFile, $title, $themeColor) {
    # Shadow
    $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 20, 20, 20))
    $g.FillEllipse($shadowBrush, ($cx - 96), ($cy - 92), 192, 192)
    $shadowBrush.Dispose()

    # Stone terrace dais
    $stoneBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(248, 244, 236))
    $g.FillEllipse($stoneBrush, ($cx - 90), ($cy - 90), 180, 180)
    $stoneBrush.Dispose()

    # Theme ring
    $ringPen = New-Object System.Drawing.Pen($themeColor, 7.0)
    $g.DrawEllipse($ringPen, ($cx - 86), ($cy - 86), 172, 172)
    $ringPen.Dispose()

    # Inner gold border
    $goldPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(235, 212, 160, 50), 3.0)
    $g.DrawEllipse($goldPen, ($cx - 78), ($cy - 78), 156, 156)
    $goldPen.Dispose()

    # Medallion
    $medPath = "$elemDir\$medallionFile"
    if (Test-Path $medPath) {
        $medImg = [System.Drawing.Bitmap]::FromFile($medPath)
        $medSize = 130
        $g.DrawImage($medImg, [int]($cx - $medSize / 2), [int]($cy - $medSize / 2), $medSize, $medSize)
        $medImg.Dispose()
    }

    # Banner plaque below
    $bannerW = 180
    $bannerH = 34
    $bannerX = [int]($cx - $bannerW / 2)
    $bannerY = [int]($cy + 74)

    $bannerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 28, 28, 30))
    $g.FillRectangle($bannerBrush, $bannerX, $bannerY, $bannerW, $bannerH)
    $bannerBrush.Dispose()

    $bannerBorder = New-Object System.Drawing.Pen($themeColor, 2.5)
    $g.DrawRectangle($bannerBorder, $bannerX, $bannerY, $bannerW, $bannerH)
    $bannerBorder.Dispose()

    $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 252, 246, 230))
    $g.DrawString($title, $titleFont, $textBrush, [float]$cx, [float]($bannerY + 17), $sf)
    $textBrush.Dispose()
}

# The 5 House Pavilions:
# Huyen (1600, 120) -> (712, 272)
$colHuyen = [System.Drawing.Color]::FromArgb(240, 75, 85, 175)
Draw-House-Pavilion 712 272 "medallion_huyen.png" "NHA HO HUYEN" $colHuyen

# Kim (300, 420) -> (192, 392)
$colKim = [System.Drawing.Color]::FromArgb(240, 40, 140, 160)
Draw-House-Pavilion 192 392 "medallion_kim.png" "NHA HO KIM" $colKim

# Lam (2900, 420) -> (1232, 392)
$colLam = [System.Drawing.Color]::FromArgb(240, 60, 150, 80)
Draw-House-Pavilion 1232 392 "medallion_lam.png" "NHA HO LAM" $colLam

# Hoang (340, 980) -> (208, 616)
$colHoang = [System.Drawing.Color]::FromArgb(240, 200, 135, 35)
Draw-House-Pavilion 208 616 "medallion_hoang.png" "NHA HO HOANG" $colHoang

# Chu (2860, 980) -> (1216, 616)
$colChu = [System.Drawing.Color]::FromArgb(240, 185, 55, 65)
Draw-House-Pavilion 1216 616 "medallion_chu.png" "NHA HO CHU" $colChu

# 6. Central Hub Pavilion Dais (1600, 1500) -> (712, 824)
$chX = 712; $chY = 824
$chShadow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(70, 20, 20, 20))
$g.FillEllipse($chShadow, ($chX - 110), ($chY - 105), 220, 220)
$chShadow.Dispose()

$chPlaza = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(250, 240, 230, 215))
$g.FillEllipse($chPlaza, ($chX - 105), ($chY - 105), 210, 210)
$chPlaza.Dispose()

$chRim1 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(240, 165, 95, 185), 7.0)
$chRim2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 215, 175, 75), 3.0)
$g.DrawEllipse($chRim1, ($chX - 100), ($chY - 100), 200, 200)
$g.DrawEllipse($chRim2, ($chX - 90), ($chY - 90), 180, 180)
$chRim1.Dispose(); $chRim2.Dispose()

# Central Hub Banner
$chW = 210; $chH = 34
$chXb = [int]($chX - $chW / 2)
$chYb = [int]($chY + 85)
$chBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 45, 30, 50))
$g.FillRectangle($chBrush, $chXb, $chYb, $chW, $chH)
$chBrush.Dispose()
$chBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(240, 215, 175, 75), 2.5)
$g.DrawRectangle($chBorder, $chXb, $chYb, $chW, $chH)
$chBorder.Dispose()

$textGold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 235, 180))
$g.DrawString("DAI SAN TRUNG TAM", $titleFont, $textGold, [float]$chX, [float]($chYb + 17), $sf)

# 7. Mausoleum Hub Dais (1600, 2600) -> (712, 1264)
$mX = 712; $mY = 1264
$mShadow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(70, 20, 20, 20))
$g.FillEllipse($mShadow, ($mX - 105), ($mY - 100), 210, 210)
$mShadow.Dispose()

$mPlaza = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(250, 235, 225, 210))
$g.FillEllipse($mPlaza, ($mX - 100), ($mY - 100), 200, 200)
$mPlaza.Dispose()

$mRim1 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(240, 195, 145, 55), 7.0)
$mRim2 = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(210, 140, 100, 40), 3.0)
$g.DrawEllipse($mRim1, ($mX - 95), ($mY - 95), 190, 190)
$g.DrawEllipse($mRim2, ($mX - 85), ($mY - 85), 170, 170)
$mRim1.Dispose(); $mRim2.Dispose()

# Mausoleum sacred inner ring
$mInnerPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230, 205, 155, 60), 2.0)
$g.DrawEllipse($mInnerPen, ($mX - 65), ($mY - 65), 130, 130)
$mInnerPen.Dispose()

# Mausoleum Banner
$mW = 210; $mH = 34
$mXb = [int]($mX - $mW / 2)
$mYb = [int]($mY + 80)
$mBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 50, 40, 25))
$g.FillRectangle($mBrush, $mXb, $mYb, $mW, $mH)
$mBrush.Dispose()
$mBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(240, 215, 175, 75), 2.5)
$g.DrawRectangle($mBorder, $mXb, $mYb, $mW, $mH)
$mBorder.Dispose()
$g.DrawString("LANG MIEU HOANG GIA", $titleFont, $textGold, [float]$mX, [float]($mYb + 17), $sf)

# 8. Final Gate Pavilion / Finish Dais (1600, 3460) -> (712, 1608)
$fX = 712; $fY = 1608
$fPlaza = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(250, 245, 235, 215))
$g.FillEllipse($fPlaza, ($fX - 90), ($fY - 85), 180, 170)
$fPlaza.Dispose()
$fRim = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(240, 185, 80, 50), 6.0)
$g.DrawEllipse($fRim, ($fX - 85), ($fY - 80), 170, 160)
$fRim.Dispose()

$fW = 200; $fH = 34
$fXb = [int]($fX - $fW / 2)
$fYb = [int]($fY + 68)
$fBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 60, 25, 20))
$g.FillRectangle($fBrush, $fXb, $fYb, $fW, $fH)
$fBrush.Dispose()
$fBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(240, 235, 190, 80), 2.5)
$g.DrawRectangle($fBorder, $fXb, $fYb, $fW, $fH)
$fBorder.Dispose()
$g.DrawString("CONG HOANG THANH", $titleFont, $textGold, [float]$fX, [float]($fYb + 17), $sf)

# Cleanup
$titleFont.Dispose(); $textGold.Dispose(); $sf.Dispose()
$g.Dispose()

# Save final composed board texture
$outPath = Join-Path $baseDir "Than_Tham_Nua_Voi_Godot\assets\maps\imperial_court_board_v1.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "Successfully built board map: $outPath"
