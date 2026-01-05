using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class SceneViewFovStencilBypassFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public LayerMask layerMask = ~0;
        public RenderPassEvent passEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    public Settings settings = new Settings();

    class Pass : ScriptableRenderPass
    {
        FilteringSettings filtering;
        readonly ShaderTagId shaderTag = new ShaderTagId("UniversalForward");
        RenderStateBlock stateBlock;

        public Pass(LayerMask layerMask)
        {
            filtering = new FilteringSettings(RenderQueueRange.all, layerMask);

            // Override ONLY stencil compare to Always (ignore your volume stencil)
            var stencil = new StencilState(
                enabled: true,
                readMask: 255,
                writeMask: 255,
                compareFunctionFront: CompareFunction.Always,
                passOperationFront: StencilOp.Keep,
                failOperationFront: StencilOp.Keep,
                zFailOperationFront: StencilOp.Keep,
                compareFunctionBack: CompareFunction.Always,
                passOperationBack: StencilOp.Keep,
                failOperationBack: StencilOp.Keep,
                zFailOperationBack: StencilOp.Keep
            );

            stateBlock = new RenderStateBlock(RenderStateMask.Stencil)
            {
                stencilState = stencil,
                stencilReference = 1 // your Ref 1
            };
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var cam = renderingData.cameraData.camera;

            // Scene View only
            if (cam == null || cam.cameraType != CameraType.SceneView)
                return;

            var sort = renderingData.cameraData.defaultOpaqueSortFlags;
            var draw = CreateDrawingSettings(shaderTag, ref renderingData, sort);

            context.DrawRenderers(renderingData.cullResults, ref draw, ref filtering, ref stateBlock);
        }
    }

    Pass pass;

    public override void Create()
    {
        pass = new Pass(settings.layerMask)
        {
            renderPassEvent = settings.passEvent
        };
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(pass);
    }
}
