extends RefCounted
## Candidate authored presentation curves. All inputs are canonical clocks.
## Knots: normalized age, shoulder drive, torso pitch, elbow fold, head pitch.
const ATTACK := [Vector4(0.0,0.0,0.0,0.0),Vector4(0.20,-0.30,-0.06,0.22),Vector4(0.45,0.48,0.11,-0.24),Vector4(0.62,0.30,0.07,-0.12),Vector4(1.0,0.0,0.0,0.0)]
const HURT := [Vector4(0.0,-0.30,-0.13,0.18),Vector4(0.18,-0.38,-0.18,0.26),Vector4(0.48,-0.20,-0.09,0.13),Vector4(1.0,0.0,0.0,0.0)]
static func curve(knots: Array, age: float) -> Vector3:
    for i in range(1,knots.size()):
        var b: Vector4=knots[i]
        if age<=b.x:
            var a: Vector4=knots[i-1]
            var u:=smoothstep(a.x,b.x,age)
            return Vector3(lerpf(a.y,b.y,u),lerpf(a.z,b.z,u),lerpf(a.w,b.w,u))
    return Vector3.ZERO
static func action(state: String, context: Dictionary) -> Vector3:
    if state=="attack":return curve(ATTACK,clampf(1.0-float(context.get("attack",0.22))/0.22,0.0,1.0))
    if state=="hurt":return curve(HURT,clampf(1.0-float(context.get("hurt",0.18))/0.18,0.0,1.0))
    if state.begins_with("flex"):
        var envelope:=smoothstep(0.0,0.25,float(context.get("flex_age",0.0)))*smoothstep(0.0,0.25,float(context.get("flex",0.0)))
        # Confident keyboard salute; canonical Flex entry/hold/exit, no extra hit.
        return Vector3(-0.65,-0.07,0.42)*envelope
    return Vector3.ZERO
