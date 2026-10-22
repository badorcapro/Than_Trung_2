using UnityEngine;

public class DemoWhatWeAreWorkingOn : MonoBehaviour
{
	public void closeDemoWhatWeAreWorkingOn()
	{
		GameHandler.instance.moveToScene("MainMenuScene");
	}
}
