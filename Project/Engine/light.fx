#ifndef _LIGHT
#define _LIGHT

#include "value.fx"
#include "func.fx"


// ========================
// Directional Light Shader
// MRT      : LIGHT
// Mesh     : RectMesh
// DS_TYPE  : NO_TEST_NO_WIRTE
// BS_TYPE  : ONE_ONE , �������� ���� ������ �� �ְ�

// Parameter
// g_int_0 : Light Idex
// g_tex_0 : PositionTargetTex
// g_tex_1 : NormalTargetTex
// ========================
struct VS_IN
{
    float3 vPos : POSITION;
    float2 vUV : TEXCOORD;
};

struct VS_OUT
{
    float4 vPosition : SV_Position;
    float2 vUV : TEXCOORD;
};

VS_OUT VS_DirLight(VS_IN _in)
{
    VS_OUT output = (VS_OUT) 0.f;
    
    output.vPosition = float4(_in.vPos * 2.f, 1.f);
    output.vUV = _in.vUV;
    
    return output;
}

struct PS_OUT
{
    float4 vDiffuse : SV_Target0;
    float4 vSpecular : SV_Target1;
};

PS_OUT PS_DirLight(VS_OUT _in)
{
    PS_OUT output = (PS_OUT) 0.f;
        
    // PositionTarget ���� ���� ȣ��� �ȼ����̴��� ������ ������ �����ؼ� ��ǥ���� Ȯ��
    float4 vViewPos = g_tex_0.Sample(g_sam_0, _in.vUV);
    
    // Deferred �ܰ迡�� �׷����� ���ٸ� ���� �� �� ����.
    if (-1.f == vViewPos.w)
        discard;
    
    // �ش� ������ Normal ���� �����´�.
    float3 vViewNormal = normalize(g_tex_1.Sample(g_sam_0, _in.vUV).xyz);
       
    // �ش� ������ ���� ���� ���⸦ ���Ѵ�.
    tLightColor LightColor = (tLightColor) 0.f;
    CalLight3D(g_int_0, vViewPos.xyz, vViewNormal, LightColor);
        
    output.vDiffuse = LightColor.vColor + LightColor.vAmbient;
    output.vSpecular = LightColor.vSpecular;
    
    output.vDiffuse.a = 1.f;
    output.vSpecular.a = 1.f;
    
    return output;
}

// ========================
// Point Light Shader
// MRT      : LIGHT
// Mesh     : SphereMesh
// DS_TYPE  : NO_TEST_NO_WIRTE
// BS_TYPE  : ONE_ONE , �������� ���� ������ �� �ְ�

// Parameter
// g_int_0 : Light Idex
// g_mat_0 : ViewInv * WorldInv
// g_tex_0 : PositionTargetTex
// g_tex_1 : NormalTargetTex
// ========================
VS_OUT VS_PointLight(VS_IN _in)
{
    VS_OUT output = (VS_OUT) 0.f;
    
    output.vPosition = mul(float4(_in.vPos, 1.f), g_matWVP);
    output.vUV = _in.vUV;
    
    return output;
}

PS_OUT PS_PointLight(VS_OUT _in)
{
    PS_OUT output = (PS_OUT) 0.f;
    
    // ȣ��� �ȼ��� ��ġ�� UV ������ ȯ��
    float2 vScreenUV = _in.vPosition.xy / g_RenderResolution;
        
    // PositionTarget ���� ���� ȣ��� �ȼ����̴��� ������ ������ �����ؼ� ��ǥ���� Ȯ��
    float4 vViewPos = g_tex_0.Sample(g_sam_0, vScreenUV);
    
    // Deferred �ܰ迡�� �׷����� ���ٸ� ���� �� �� ����.
    if (-1.f == vViewPos.w)
    {
        discard;
    }
                
    // Sphere �����޽��� ���� �������� ��������.
    float3 vLocal = mul(float4(vViewPos.xyz, 1.f), g_mat_0).xyz;
    
    // ���ð������� ��(Sphere) ���ο� �ִ��� üũ�Ѵ�.
    if (0.5f < length(vLocal))
    {
        discard;
    }
    
    // �ش� ������ Normal ���� �����´�.
    float3 vViewNormal = normalize(g_tex_1.Sample(g_sam_0, vScreenUV).xyz);
       
    // �ش� ������ ���� ���� ���⸦ ���Ѵ�.
    tLightColor LightColor = (tLightColor) 0.f;
    CalLight3D(g_int_0, vViewPos.xyz, vViewNormal, LightColor);
        
    output.vDiffuse = LightColor.vColor + LightColor.vAmbient;
    output.vSpecular = LightColor.vSpecular;
    output.vDiffuse.a = 1.f;
    output.vSpecular.a = 1.f;
    
    return output;
}


// ========================
// Spot Light Shader
// MRT      : LIGHT
// Mesh     : ConeMesh
// DS_TYPE  : NO_TEST_NO_WIRTE
// BS_TYPE  : ONE_ONE , �������� ���� ������ �� �ְ�

// Parameter
// g_int_0 : Light Idex
// g_mat_0 : ViewInv * WorldInv
// g_tex_0 : PositionTargetTex
// g_tex_1 : NormalTargetTex
// ========================
VS_OUT VS_SpotLight(VS_IN _in)
{
    VS_OUT output = (VS_OUT) 0.f;
    
    output.vPosition = mul(float4(_in.vPos, 1.f), g_matWVP);
    output.vUV = _in.vUV;
    
    return output;
}
PS_OUT PS_SpotLight(VS_OUT _in)
{
    PS_OUT output = (PS_OUT) 0.f;
    
    // ȣ��� �ȼ��� ��ġ�� UV ������ ȯ��
    float2 vScreenUV = _in.vPosition.xy / g_RenderResolution;
        
    // PositionTarget ���� ���� ȣ��� �ȼ����̴��� ������ ������ �����ؼ� ��ǥ���� Ȯ��
    float4 vViewPos = g_tex_0.Sample(g_sam_0, vScreenUV);
    
    // Deferred �ܰ迡�� �׷����� ���ٸ� ���� �� �� ����.
    if (-1.f == vViewPos.w)
    {
        discard;
    }
                
    // Cone �����޽��� ���� �������� ��������.
    float3 vLocal = mul(float4(vViewPos.xyz, 1.f), g_mat_0).xyz;
    
    // ���ð������� Cone Mesh ���ο� �ִ��� üũ�Ѵ�.
    // 1 : 0.5 = vLocal.z : fRange
    float fRange = vLocal.z * 0.5f;
    
    if (fRange < length(vLocal.xy) || 1 < vLocal.z)
    {
        discard;
    }
    
    // �ش� ������ Normal ���� �����´�.
    float3 vViewNormal = normalize(g_tex_1.Sample(g_sam_0, vScreenUV).xyz);
    
    // �ش� ������ ���� ���� ���⸦ ���Ѵ�.
    tLightColor LightColor = (tLightColor) 0.f;
    CalLight3D(g_int_0, vViewPos.xyz, vViewNormal, LightColor);
        
    output.vDiffuse = LightColor.vColor + LightColor.vAmbient;
    output.vSpecular = LightColor.vSpecular;
    output.vDiffuse.a = 1.f;
    output.vSpecular.a = 1.f;
    
    //output.vDiffuse = float4(0.f, 1.f, 0.f, 1.f);
    return output;
}

#endif