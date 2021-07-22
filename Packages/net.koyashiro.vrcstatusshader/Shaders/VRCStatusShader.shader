Shader "koyashiro/VRCStatusShader"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            static uint2 RESOLUTION = uint2(64, 64);
            static uint2 DOT_MATRIX = uint2(1, 1);
            static uint2 CHAR_MATRIX = uint2(5, 7);

            static bool UPPER_ALPHABET_MATRICES[3][7][5] = {
                // X
                {
                    { 1, 0, 0, 0, 1 },
                    { 1, 0, 0, 0, 1 },
                    { 0, 1, 0, 1, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 1, 0, 1, 0 },
                    { 1, 0, 0, 0, 1 },
                    { 1, 0, 0, 0, 1 },
                },
                // Y
                {
                    { 1, 0, 0, 0, 1 },
                    { 1, 0, 0, 0, 1 },
                    { 1, 0, 0, 0, 1 },
                    { 0, 1, 0, 1, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 0, 1, 0, 0 },
                },
                // Z
                {
                    { 1, 1, 1, 1, 1 },
                    { 0, 0, 0, 0, 1 },
                    { 0, 0, 0, 1, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 1, 0, 0, 0 },
                    { 1, 0, 0, 0, 0 },
                    { 1, 1, 1, 1, 1 },
                },
            };

            static bool SIGN_MATRICES[3][7][5] = {
                // -
                {
                    { 0, 0, 0, 0, 0 },
                    { 0, 0, 0, 0, 0 },
                    { 0, 0, 0, 0, 0 },
                    { 1, 1, 1, 1, 1 },
                    { 0, 0, 0, 0, 0 },
                    { 0, 0, 0, 0, 0 },
                    { 0, 0, 0, 0, 0 },
                },
                // +-
                {
                    { 0, 0, 1, 0, 0 },
                    { 0, 1, 1, 1, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 0, 0, 0, 0 },
                    { 0, 0, 0, 0, 0 },
                    { 0, 1, 1, 1, 0 },
                    { 0, 0, 0, 0, 0 },
                },
                // +
                {
                    { 0, 0, 0, 0, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 1, 1, 1, 1, 1 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 0, 0, 0, 0 },
                },
            };

            static bool LOWER_ALPHABET_MATRICES[1][7][5] = {
                // x
                {
                    { 0, 0, 0, 0, 0 },
                    { 0, 0, 0, 0, 0 },
                    { 1, 0, 0, 0, 1 },
                    { 0, 1, 0, 1, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 1, 0, 1, 0 },
                    { 1, 0, 0, 0, 1 },
                },
            };

            static bool NUMBER_MATRICES[10][7][5] = {
                // 0
                {
                    { 0, 1, 1, 1, 0 },
                    { 1, 0, 0, 0, 1 },
                    { 1, 0, 0, 1, 1 },
                    { 1, 0, 1, 0, 1 },
                    { 1, 1, 0, 0, 1 },
                    { 1, 0, 0, 0, 1 },
                    { 0, 1, 1, 1, 0 },
                },
                // 1
                {
                    { 0, 0, 1, 0, 0 },
                    { 0, 1, 1, 0, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 1, 1, 1, 0 },
                },
                // 2
                {
                    { 0, 1, 1, 1, 0 },
                    { 1, 0, 0, 0, 1 },
                    { 0, 0, 0, 0, 1 },
                    { 0, 0, 0, 1, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 1, 0, 0, 0 },
                    { 1, 1, 1, 1, 1 },
                },
                // 3
                {
                    { 0, 1, 1, 1, 0 },
                    { 1, 0, 0, 0, 1 },
                    { 0, 0, 0, 0, 1 },
                    { 0, 0, 1, 1, 0 },
                    { 0, 0, 0, 0, 1 },
                    { 1, 0, 0, 0, 1 },
                    { 0, 1, 1, 1, 0 },
                },
                // 4
                {
                    { 0, 0, 0, 1, 0 },
                    { 0, 0, 1, 1, 0 },
                    { 0, 1, 0, 1, 0 },
                    { 1, 0, 0, 1, 0 },
                    { 1, 1, 1, 1, 1 },
                    { 0, 0, 0, 1, 0 },
                    { 0, 0, 0, 1, 0 },
                },
                // 5
                {
                    { 1, 1, 1, 1, 1 },
                    { 1, 0, 0, 0, 0 },
                    { 1, 1, 1, 1, 0 },
                    { 0, 0, 0, 0, 1 },
                    { 0, 0, 0, 0, 1 },
                    { 1, 0, 0, 0, 1 },
                    { 0, 1, 1, 1, 0 },
                },
                // 6
                {
                    { 0, 1, 1, 1, 0 },
                    { 1, 0, 0, 0, 1 },
                    { 1, 0, 0, 0, 0 },
                    { 1, 1, 1, 1, 0 },
                    { 1, 0, 0, 0, 1 },
                    { 1, 0, 0, 0, 1 },
                    { 0, 1, 1, 1, 0 },
                },
                // 7
                {
                    { 1, 1, 1, 1, 1 },
                    { 0, 0, 0, 0, 1 },
                    { 0, 0, 0, 1, 0 },
                    { 0, 0, 1, 0, 0 },
                    { 0, 1, 0, 0, 0 },
                    { 0, 1, 0, 0, 0 },
                    { 0, 1, 0, 0, 0 },
                },
                // 8
                {
                    { 0, 1, 1, 1, 0 },
                    { 1, 0, 0, 0, 1 },
                    { 1, 0, 0, 0, 1 },
                    { 0, 1, 1, 1, 0 },
                    { 1, 0, 0, 0, 1 },
                    { 1, 0, 0, 0, 1 },
                    { 0, 1, 1, 1, 0 },
                },
                // 9
                {
                    { 0, 1, 1, 1, 0 },
                    { 1, 0, 0, 0, 1 },
                    { 1, 0, 0, 0, 1 },
                    { 0, 1, 1, 1, 1 },
                    { 0, 0, 0, 0, 1 },
                    { 0, 0, 0, 0, 1 },
                    { 0, 1, 1, 1, 0 },
                },
            };

            static uint2 WORLD_POS_X_LABEL_POSITION = uint2(3, 4);
            static uint2 WORLD_POS_Y_LABEL_POSITION = uint2(3, 13);
            static uint2 WORLD_POS_Z_LABEL_POSITION = uint2(3, 22);

            static uint2 WORLD_POS_X_POINT_POSITION = uint2(54, 10);
            static uint2 WORLD_POS_Y_POINT_POSITION = uint2(54, 19);
            static uint2 WORLD_POS_Z_POINT_POSITION = uint2(54, 28);

            static uint2 WORLD_POS_X_SIGN_POSITION = uint2(11, 4);
            static uint2 WORLD_POS_Y_SIGN_POSITION = uint2(11, 13);
            static uint2 WORLD_POS_Z_SIGN_POSITION = uint2(11, 22);

            static uint2 WORLD_POS_X_POSITIONS[7] = {
                uint2(18, 4),
                uint2(24, 4),
                uint2(30, 4),
                uint2(36, 4),
                uint2(42, 4),
                uint2(48, 4),
                uint2(56, 4),
            };
            static uint2 WORLD_POS_Y_POSITIONS[7] = {
                uint2(18, 13),
                uint2(24, 13),
                uint2(30, 13),
                uint2(36, 13),
                uint2(42, 13),
                uint2(48, 13),
                uint2(56, 13),
            };
            static uint2 WORLD_POS_Z_POSITIONS[7] = {
                uint2(18, 22),
                uint2(24, 22),
                uint2(30, 22),
                uint2(36, 22),
                uint2(42, 22),
                uint2(48, 22),
                uint2(56, 22),
            };

            static uint2 SCREEN_RESOLUTION_CROSS_MARK_POSITION = uint2(30, 32);

            static uint2 SCREEN_RESOLUTION_X_POSITIONS[4] = {
                uint2(3, 32),
                uint2(9, 32),
                uint2(15, 32),
                uint2(21, 32),
            };

            static uint2 SCREEN_RESOLUTION_Y_POSITIONS[4] = {
                uint2(39, 32),
                uint2(45, 32),
                uint2(51, 32),
                uint2(57, 32),
            };

            static uint2 FPS_POSITIONS[3] = {
                uint2(33, 43),
                uint2(27, 43),
                uint2(21, 43),
            };

            static uint2 TIME_POSITIONS[6] = {
                uint2(33, 54),
                uint2(27, 54),
                uint2(21, 54),
                uint2(15, 54),
                uint2(9, 54),
                uint2(3, 54),
            };

            uint2 convertToDotPos(float2 uv)
            {
                return uint2(uv.x * RESOLUTION.x, RESOLUTION.y - uv.y * RESOLUTION.y);
            }

            bool inRange(uint2 dotPos, uint2 position, uint2 m)
            {
                return position.x <= dotPos.x && dotPos.x < position.x + m.x && position.y <= dotPos.y && dotPos.y < position.y + m.y;
            }

            uint2 convertToMatrixPos(uint2 dotPos, uint2 position)
            {
                return dotPos - position;
            }

            uint convertToDigitNumber(float number, int digit)
            {
                return (int)(abs(number) * 1000 / pow(10, digit + 3)) % 10;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Dot position
                uint2 dotPos = convertToDotPos(i.uv);

                // X label
                if (inRange(dotPos, WORLD_POS_X_LABEL_POSITION, CHAR_MATRIX))
                {
                    uint2 matrixPos = convertToMatrixPos(dotPos, WORLD_POS_X_LABEL_POSITION);
                    if (UPPER_ALPHABET_MATRICES[0][matrixPos.y][matrixPos.x])
                    {
                        return fixed4(1, 1, 1, 1);
                    }
                }

                // Y label
                if (inRange(dotPos, WORLD_POS_Y_LABEL_POSITION, CHAR_MATRIX))
                {
                    uint2 matrixPos = convertToMatrixPos(dotPos, WORLD_POS_Y_LABEL_POSITION);
                    if (UPPER_ALPHABET_MATRICES[1][matrixPos.y][matrixPos.x])
                    {
                        return fixed4(1, 1, 1, 1);
                    }
                }

                // Z label
                if (inRange(dotPos, WORLD_POS_Z_LABEL_POSITION, CHAR_MATRIX))
                {
                    uint2 matrixPos = convertToMatrixPos(dotPos, WORLD_POS_Z_LABEL_POSITION);
                    if (UPPER_ALPHABET_MATRICES[2][matrixPos.y][matrixPos.x])
                    {
                        return fixed4(1, 1, 1, 1);
                    }
                }

                // X sign
                if (inRange(dotPos, WORLD_POS_X_SIGN_POSITION, CHAR_MATRIX))
                {
                    float index = (uint)sign(i.worldPos.x) + 1;
                    uint2 matrixPos = convertToMatrixPos(dotPos, WORLD_POS_X_SIGN_POSITION);
                    if (SIGN_MATRICES[index][matrixPos.y][matrixPos.x])
                    {
                        return fixed4(1, 1, 1, 1);
                    }
                }

                // Y sign
                if (inRange(dotPos, WORLD_POS_Y_SIGN_POSITION, CHAR_MATRIX))
                {
                    float index = sign(i.worldPos.y) + 1;
                    uint2 matrixPos = convertToMatrixPos(dotPos, WORLD_POS_Y_SIGN_POSITION);
                    if (SIGN_MATRICES[index][matrixPos.y][matrixPos.x])
                    {
                        return fixed4(1, 1, 1, 1);
                    }
                }

                // Z sign
                if (inRange(dotPos, WORLD_POS_Z_SIGN_POSITION, CHAR_MATRIX))
                {
                    float index = sign(i.worldPos.z) + 1;
                    uint2 matrixPos = convertToMatrixPos(dotPos, WORLD_POS_Z_SIGN_POSITION);
                    if (SIGN_MATRICES[index][matrixPos.y][matrixPos.x])
                    {
                        return fixed4(1, 1, 1, 1);
                    }
                }

                // X decimal point
                if (inRange(dotPos, WORLD_POS_X_POINT_POSITION, DOT_MATRIX))
                {
                    return fixed4(1, 1, 1, 1);
                }

                // Y decimal point
                if (inRange(dotPos, WORLD_POS_Y_POINT_POSITION, DOT_MATRIX))
                {
                    return fixed4(1, 1, 1, 1);
                }

                // Z decimal point
                if (inRange(dotPos, WORLD_POS_Z_POINT_POSITION, DOT_MATRIX))
                {
                    return fixed4(1, 1, 1, 1);
                }

                // X position
                for (int d = -1; d < 6; d++)
                {
                    uint index = 5 - d;
                    if(inRange(dotPos, WORLD_POS_X_POSITIONS[index], CHAR_MATRIX))
                    {
                        uint number = convertToDigitNumber(i.worldPos.x, d);
                        uint2 matrixPos = convertToMatrixPos(dotPos, WORLD_POS_X_POSITIONS[index]);
                        if (NUMBER_MATRICES[number][matrixPos.y][matrixPos.x])
                        {
                            return fixed4(1, 1, 1, 1);
                        }
                    }
                }

                // Y position
                for (int d = -1; d < 6; d++)
                {
                    uint index = 5 - d;
                    if(inRange(dotPos, WORLD_POS_Y_POSITIONS[index], CHAR_MATRIX))
                    {
                        uint number = convertToDigitNumber(i.worldPos.y, d);
                        uint2 matrixPos = convertToMatrixPos(dotPos, WORLD_POS_Y_POSITIONS[index]);
                        if (NUMBER_MATRICES[number][matrixPos.y][matrixPos.x])
                        {
                            return fixed4(1, 1, 1, 1);
                        }
                    }
                }

                // Z position
                for (int d = -1; d < 6; d++)
                {
                    uint index = 5 - d;
                    if(inRange(dotPos, WORLD_POS_Z_POSITIONS[index], CHAR_MATRIX))
                    {
                        uint number = convertToDigitNumber(i.worldPos.z, d);
                        uint2 matrixPos = convertToMatrixPos(dotPos, WORLD_POS_Z_POSITIONS[index]);
                        if (NUMBER_MATRICES[number][matrixPos.y][matrixPos.x])
                        {
                            return fixed4(1, 1, 1, 1);
                        }
                    }
                }

                // Screen resolution cross mark
                if (inRange(dotPos, SCREEN_RESOLUTION_CROSS_MARK_POSITION, CHAR_MATRIX))
                {
                    uint2 matrixPos = convertToMatrixPos(dotPos, SCREEN_RESOLUTION_CROSS_MARK_POSITION);
                    if (LOWER_ALPHABET_MATRICES[0][matrixPos.y][matrixPos.x])
                    {
                        return fixed4(1, 1, 1, 1);
                    }
                }

                // Screen resolution X
                for (uint d = 0; d < 4; d++)
                {
                    uint index = 3 - d;
                    if (inRange(dotPos, SCREEN_RESOLUTION_X_POSITIONS[index], CHAR_MATRIX))
                    {
                        uint number = convertToDigitNumber(_ScreenParams.x, d);
                        uint2 matrixPos = convertToMatrixPos(dotPos, SCREEN_RESOLUTION_X_POSITIONS[index]);
                        if (NUMBER_MATRICES[number][matrixPos.y][matrixPos.x])
                        {
                            return fixed4(1, 1, 1, 1);
                        }
                    }
                }

                // Screen resolution Y
                for (uint d = 0; d < 4; d++)
                {
                    uint index = 3 - d;
                    if (inRange(dotPos, SCREEN_RESOLUTION_Y_POSITIONS[index], CHAR_MATRIX))
                    {
                        uint number = convertToDigitNumber(_ScreenParams.y, d);
                        uint2 matrixPos = convertToMatrixPos(dotPos, SCREEN_RESOLUTION_Y_POSITIONS[index]);
                        if (NUMBER_MATRICES[number][matrixPos.y][matrixPos.x])
                        {
                            return fixed4(1, 1, 1, 1);
                        }
                    }
                }

                // fps
                for (uint d = 0; d < 3; d++)
                {
                    if (inRange(dotPos, FPS_POSITIONS[d], CHAR_MATRIX))
                    {
                        uint number = convertToDigitNumber(unity_DeltaTime.y, d);
                        uint2 matrixPos = convertToMatrixPos(dotPos, FPS_POSITIONS[d]);
                        if (NUMBER_MATRICES[number][matrixPos.y][matrixPos.x])
                        {
                            return fixed4(1, 1, 1, 1);
                        }
                    }
                }

                // time
                for (uint d = 0; d < 7; d++)
                {
                    if (inRange(dotPos, TIME_POSITIONS[d], CHAR_MATRIX))
                    {
                        uint number = convertToDigitNumber(_Time.y, d);
                        uint2 matrixPos = convertToMatrixPos(dotPos, TIME_POSITIONS[d]);
                        if (NUMBER_MATRICES[number][matrixPos.y][matrixPos.x])
                        {
                            return fixed4(1, 1, 1, 1);
                        }
                    }
                }

                return fixed4(0, 0, 0, 1);
            }
            ENDCG
        }
    }
}
