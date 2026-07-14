import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

interface LivenessSessionResponse {
  sessionId: string;
  authToken?: string;
}

interface VerifyBiometricsResponse {
  isMatch: boolean;
  livenessDecision: string;
  errorMessage?: string;
}

const AZURE_FACE_API_KEY = Deno.env.get("AZURE_FACE_API_KEY") ?? "";
const AZURE_FACE_ENDPOINT = Deno.env.get("AZURE_FACE_ENDPOINT") ?? "";

function corsHeaders() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-action",
  };
}

async function handleCreateSession(): Promise<Response> {
  const url = `${AZURE_FACE_ENDPOINT}/face/v1.0/detectLivenessWithVerify/sessions`;
  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Ocp-Apim-Subscription-Key": AZURE_FACE_API_KEY,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      livenessOperationMode: "Passive",
      deviceCorrelationId: crypto.randomUUID(),
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    return new Response(
      JSON.stringify({ error: `Azure session creation failed: ${errorBody}` }),
      { status: response.status, headers: { ...corsHeaders(), "Content-Type": "application/json" } },
    );
  }

  const data = await response.json() as LivenessSessionResponse;
  return new Response(JSON.stringify(data), {
    status: 200,
    headers: { ...corsHeaders(), "Content-Type": "application/json" },
  });
}

async function handleVerify(request: Request): Promise<Response> {
  const formData = await request.formData();
  const photo = formData.get("photo") as File | null;
  const coordsStr = formData.get("humanTargetFaceCoordinates") as string | null;
  const verifySessionId = formData.get("verifySessionId") as string | null;

  if (!photo || !coordsStr || !verifySessionId) {
    return new Response(
      JSON.stringify({
        isMatch: false,
        livenessDecision: "error",
        errorMessage: "Missing required fields: photo, humanTargetFaceCoordinates, verifySessionId",
      }),
      { status: 400, headers: { ...corsHeaders(), "Content-Type": "application/json" } },
    );
  }

  let targetFace: number[] | undefined;
  try {
    const coords = JSON.parse(coordsStr) as Record<string, number>;
    if (coords.left !== undefined && coords.top !== undefined &&
        coords.width !== undefined && coords.height !== undefined) {
      targetFace = [
        Math.round(coords.left),
        Math.round(coords.top),
        Math.round(coords.width),
        Math.round(coords.height),
      ];
    }
  } catch {
    // coordinates parsing failed; proceed without targetFace
  }

  const arrayBuffer = await photo.arrayBuffer();
  const blob = new Blob([arrayBuffer], { type: photo.type || "image/jpeg" });

  const verifyUrl = targetFace
    ? `${AZURE_FACE_ENDPOINT}/face/v1.0/detectLivenessWithVerify/sessions/${verifySessionId}/verify?targetFace=${targetFace.join(",")}`
    : `${AZURE_FACE_ENDPOINT}/face/v1.0/detectLivenessWithVerify/sessions/${verifySessionId}/verify`;

  const verifyResponse = await fetch(verifyUrl, {
    method: "POST",
    headers: {
      "Ocp-Apim-Subscription-Key": AZURE_FACE_API_KEY,
      "Content-Type": "application/octet-stream",
    },
    body: blob,
  });

  if (!verifyResponse.ok) {
    const errorBody = await verifyResponse.text();
    return new Response(
      JSON.stringify({
        isMatch: false,
        livenessDecision: "error",
        errorMessage: `Azure verification failed: ${errorBody}`,
      }),
      { status: verifyResponse.status, headers: { ...corsHeaders(), "Content-Type": "application/json" } },
    );
  }

  const verifyData = (await verifyResponse.json()) as Record<string, unknown>;

  const result: VerifyBiometricsResponse = {
    isMatch: verifyData["isMatch"] as boolean ?? false,
    livenessDecision: verifyData["livenessDecision"] as string ?? "error",
    errorMessage: verifyData["errorMessage"] as string | undefined,
  };

  return new Response(JSON.stringify(result), {
    status: 200,
    headers: { ...corsHeaders(), "Content-Type": "application/json" },
  });
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders() });
  }

  const action = req.headers.get("x-action");

  try {
    switch (action) {
      case "create-session":
        return await handleCreateSession();
      case "verify":
        return await handleVerify(req);
      default:
        return new Response(
          JSON.stringify({ error: `Unknown action: ${action}` }),
          { status: 400, headers: { ...corsHeaders(), "Content-Type": "application/json" } },
        );
    }
  } catch (error) {
    return new Response(
      JSON.stringify({
        isMatch: false,
        livenessDecision: "error",
        errorMessage: `Internal server error: ${error instanceof Error ? error.message : String(error)}`,
      }),
      { status: 500, headers: { ...corsHeaders(), "Content-Type": "application/json" } },
    );
  }
});
