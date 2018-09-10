using UnityEngine;

public class Rotate : MonoBehaviour {
	[Range(-360, 360)]
	public float Velocity = 10;
	// Use this for initialization
	void Start() {

	}
	float rotation;
	// Update is called once per frame
	void Update() {
		rotation += Time.deltaTime * Velocity;
		rotation %= 360;

		transform.localEulerAngles = new Vector3(0, rotation, 0);
	}
}
