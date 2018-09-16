using UnityEngine;

[ExecuteInEditMode]
public class Hexelate : MonoBehaviour {
	public Material mat;
	void OnRenderImage(RenderTexture src, RenderTexture dest) {
		Graphics.Blit(src, dest, mat);
	}
}