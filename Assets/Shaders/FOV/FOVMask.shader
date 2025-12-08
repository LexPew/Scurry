Shader "Custom/FOVMask"
{
    SubShader {
        Tags { "RenderType" = "Opaque" "Queue"="Geometry-1" "RendererPipeline" = "UniversalPipeline"}

        Pass{
            Blend Zero One
            ZWrite Off

            Stencil{
                Ref 1
                Pass Replace
            }
        }
    }
}
