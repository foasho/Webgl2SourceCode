    #version 300 es
		precision mediump float;

    uniform mat4 uModelViewMatrix;
    uniform mat4 uProjectionMatrix;
    uniform mat4 uNormalMatrix;
    // Lights
    uniform vec3 uLightDirection;// 光源の方向
    uniform vec4 uLightAmbient; // 光源の環境光
    uniform vec4 uLightDiffuse; // LightDirectionの色
    uniform vec4 uLightSpecular;// 鏡面反射光の色
    // Materials
    uniform vec4 uMaterialAmbient;// マテリアルの環境光
    uniform vec4 uMaterialDiffuse;// マテリアルの色
    uniform vec4 uMaterialSpecular;
    uniform float uShininess;

    in vec3 aVertexPosition;
    in vec3 aVertexNormal;

    out vec4 vVertexColor;

    void main(void) {
      // 位置をモデルビュー座標に変換
      vec4 vertex = uModelViewMatrix * vec4(aVertexPosition, 1.0);

      // 頂点の法線
      vec3 N = vec3(uNormalMatrix * vec4(aVertexNormal, 1.0));

      // 正規化された光の方向
      vec3 L = normalize(uLightDirection);

      // Lambertの拡散反射量
      float lambertTerm = dot(N, -L);

      // Ambient (光源とマテリアルの環境光の積)
      vec4 Ia = uLightAmbient * uMaterialAmbient;
      // Diffuse 拡散光の初期値
      vec4 Id = vec4(0.0, 0.0, 0.0, 1.0);
      // Specular 鏡面反射の初期値
      vec4 Is = vec4(0.0, 0.0, 0.0, 1.0);

      if (lambertTerm > 0.0) {
        Id = uLightDiffuse * uMaterialDiffuse * lambertTerm;
        vec3 eyeVec = -vec3(vertex.xyz); // 視点ベクトル
        vec3 E = normalize(eyeVec);
        vec3 R = reflect(L, N);// 鏡面反射ベクトル
        // 鏡面反射光の強さ
        float val = max(dot(R, E), 0.0);
        float specular = 0.0;
        if (val > 0.0){
          specular = pow(val, uShininess);
        }
        Is = uLightSpecular * uMaterialSpecular * specular;
      }

      // Set varying to be used in fragment shader
      vVertexColor = vec4(vec3(Ia + Id + Is), 1.0);
      // 位置をプロジェクション座標に変換
      gl_Position = uProjectionMatrix * vertex;
    }