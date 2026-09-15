; Lab 8 - Planet Information Calculator (Base Version)
; Student: Duncan Lamb
; Date: November 11, 2025
;
; Description: Calculates gravity, escape velocity, and density for planets

includelib ucrt.lib
includelib legacy_stdio_definitions.lib

EXTERN printf: PROC
EXTERN scanf: PROC
ExitProcess proto
ReadString proto
WriteString proto
WriteInt64 proto
Crlf proto

                                                                                    ;_______________________________________________
                                                                                    ; MACRO: mReadReal8
                                                                                    ; Purpose: Read a double from user input
                                                                                    ; Parameter: readVal = memory location to store the value
                                                                                    ;_______________________________________________
mReadReal8 MACRO readVal
    LOCAL fmt
    .data
    fmt byte "%lf",0
    .code
    push rcx
    push rdx
    sub rsp, 56
    mov rcx, offset fmt
    mov rdx, offset readVal
    call scanf
    add rsp, 56
    pop rdx
    pop rcx
ENDM

                                                                                    ;_______________________________________________
                                                                                    ; MACRO: mWriteReal8
                                                                                    ; Purpose: Write a double to output
                                                                                    ; Parameter: doubleVal = memory location of value to print
                                                                                    ;_______________________________________________
mWriteReal8 MACRO doubleVal
    LOCAL fmt
    .data
    fmt byte "%g",0
    .code
    push rcx
    push rdx
    sub rsp, 56
    lea rcx, fmt
    movsd xmm1, REAL8 PTR [doubleVal]      ; Load double into xmm1 (where printf expects it)
    call printf
    add rsp, 56
    pop rdx
    pop rcx
ENDM

                                                                                    ;_______________________________________________
                                                                                    ; MACRO: checkInput - THIS MUST BE A MACRO
                                                                                    ; Purpose: Validate input is positive and below maximum
                                                                                    ; Parameters:
                                                                                    ;   value = REAL8 value to check
                                                                                    ;   maxVal = REAL8 maximum allowed value
                                                                                    ;   errorMsg = error message to display if invalid
                                                                                    ;_______________________________________________
checkInput MACRO value, maxVal, errorMsg
    LOCAL valid, invalid, exit_check
    
    ; Check if value > 0
    fld value                                                                       ; Load value onto FPU stack
    fldz                                                                            ; Load 0.0 onto FPU stack
    fcomip st(0), st(1)                                                             ; Compare and pop: is 0 < value?
    jae invalid                                                                     ; If value <= 0, invalid
    
    ; Check if value < maxVal
    fld maxVal                                                                      ; Load max value
    fcomip st(0), st(1)                                                             ; Compare and pop: is maxVal > value?
    jbe invalid                                                                     ; If value >= maxVal, invalid
    
    ; Valid input
    fstp st(0)                                                                      ; Pop value from stack
    mov eax, 1                                                                      ; Return valid flag
    jmp exit_check
    
invalid:
    ; Invalid input
    fstp st(0)                                                                      ; Pop value from stack
    mov rdx, offset errorMsg
    call WriteString
    call Crlf
    xor eax, eax                                                                    ; Return invalid flag
    
exit_check:
ENDM

                                                                                    ;_______________________________________________
                                                                                    ; MACRO: printPlanetInfo - THIS MUST BE A MACRO
                                                                                    ; Purpose: Display all planet information
                                                                                    ; Parameter: planetPtr = address of Planet structure
                                                                                    ;_______________________________________________
printPlanetInfo MACRO planetPtr
    LOCAL nameStr, massStr, radiusStr, gravityStr, escVelStr, densityStr
    .data
    nameStr byte "Facts about ",0
    massStr byte "Mass (kg): ",0
    radiusStr byte "Radius (m): ",0
    gravityStr byte "Gravity (m/s^2): ",0
    escVelStr byte "Escape velocity (m/s): ",0
    densityStr byte "Density (kg/m^3): ",0
    .code
    
    mov rdx, offset nameStr                                                         ; Print "Facts about [whatever planet was inputed]"
    call WriteString
    mov rdx, offset myPlanet.name_buffer
    call WriteString
    call Crlf
    
    mov rdx, offset massStr                                                         ; Print mass
    call WriteString
    mov rdx, offset myPlanet.mass
    mWriteReal8 rdx
    call Crlf
    
    mov rdx, offset radiusStr                                                       ; Print radius
    call WriteString
    mov rax, myPlanet.radius
    call WriteInt64
    call Crlf
    
    mov rdx, offset gravityStr                                                      ; Print gravity
    call WriteString
    mov rdx, offset myPlanet.gravity
    mWriteReal8 rdx
    call Crlf
    
    mov rdx, offset escVelStr                                                       ; Print escape velocity
    call WriteString
    mov rdx, offset myPlanet.escapeVelocity
    mWriteReal8 rdx
    call Crlf
    
    mov rdx, offset densityStr                                                      ; Print density
    call WriteString
    mov rdx, offset myPlanet.density
    mWriteReal8 rdx
    call Crlf
ENDM

                                                                                    ;_______________________________________________
                                                                                    ; STRUCTURE: Planet - THIS MUST BE A STRUCT
                                                                                    ; Contains all information about a planet
                                                                                    ;_______________________________________________
Planet STRUCT
    name_buffer byte 10 dup(?)                                                      ; Offset 0: Planet name (10 chars)
    mass real8 ?                                                                    ; Offset 10: Mass in kg
    radius qword ?                                                                  ; Offset 18: Radius in meters
    gravity real8 ?                                                                 ; Offset 26: Surface gravity m/s^2
    escapeVelocity real8 ?                                                          ; Offset 34: Escape velocity m/s
    density real8 ?                                                                 ; Offset 42: Density kg/m^3
Planet ENDS

                                                                                    
                                                                                    ; DATA SECTION
.data
    ; Physical constants
    G_CONSTANT real8 6.6743e-11                                                     ; the gravitational constant
    TWO real8 2.0                                                                   ; For escape velocity calculation
    THREE real8 3.0                                                                 ; For density calculation
    FOUR real8 4.0                                                                  ; For density calculation
    PI real8 3.14159265358979323846                                                 ; Pi for density calculation
    
    ; Input validation limits
    MAX_MASS real8 1.0e28                                                           ; Maximum mass allowed
    MAX_RADIUS real8 72000000.0                                                     ; Maximum radius allowed
    
    myPlanet Planet <>                                                              ; Planet structure instance
    
    promptName byte "Enter the planet's name: ",0                                   ; User prompts
    promptMass byte "Enter the mass in kilograms: ",0
    promptRadius byte "Enter the radius in meters: ",0
    
    errorMass byte "Error: Mass must be positive and less than 1e28",0              ; Error messages
    errorRadius byte "Error: Radius must be positive and less than 72000000",0
    
    tempMass real8 ?                                                                ; Temporary storage
    tempRadius real8 ?
    tempRadiusInt qword ?                                                           ; Temporary for radius conversion

                                                                                    
                                                                                    ; CODE SECTION
.code
main proc

                                                                                    ; STEP 1: Get planet name from user
    mov rdx, offset promptName
    call WriteString
    lea rdx, myPlanet.name_buffer                                                   ; Load address of name buffer in structure
    mov rcx, SIZEOF myPlanet.name_buffer                                            ; Maximum 10 characters
    call ReadString
    
                                                                                    ; STEP 2: Get and validate mass
input_mass:
    mov rdx, offset promptMass
    call WriteString
    mReadReal8 tempMass                                                             ; Read mass into temporary variable
    
    ; SKIP VALIDATION FOR TESTING
    ; checkInput tempMass, MAX_MASS, errorMass
    ; test eax, eax                                                                 ; Check if valid (eax = 1) or invalid (eax = 0)
    ; jz input_mass                                                                 ; If invalid, ask again
    
    ; Store valid mass in structure
    fld tempMass
    fstp myPlanet.mass
    
                                                                                    ; STEP 3: Get and validate radius
input_radius:
    mov rdx, offset promptRadius
    call WriteString
    mReadReal8 tempRadius                                                           ; Read radius into temporary variable
    
    ; SKIP VALIDATION FOR TESTING
    ; checkInput tempRadius, MAX_RADIUS, errorRadius
    ; test eax, eax                                                                 ; Check if valid
    ; jz input_radius                                                               ; If invalid, ask again
    
    ; Convert radius from real8 to qword and store
    fld tempRadius
    fistp myPlanet.radius                   ; Convert to integer and store
    
                                                                                    ; STEP 4: Calculate Gravity
                                                                                    ; Formula: g = (G * M) / r^2
                                                                                    ; Where: G = gravitational constant
                                                                                    ;        M = mass
                                                                                    ;        r = radius

    fld myPlanet.mass                                                               ; st(0) = M
    fmul G_CONSTANT                                                                 ; st(0) = G * M
    
    fild myPlanet.radius                                                            ; st(0) = r, st(1) = G*M
    fmul st(0), st(0)                                                               ; st(0) = r^2, st(1) = G*M
    
    fdivr st(1), st(0)                                                              ; st(1) = (G*M) / r^2
    fstp st(0)                                                                      ; Pop r^2, leaving gravity in st(0)
    fstp myPlanet.gravity                                                           ; Store gravity
    
                                                                                    ; STEP 5: Calculate Escape Velocity
                                                                                    ; Formula: v = sqrt(2 * G * M / r)
                                                                                    ; This is minimum velocity to escape gravity

                                                                                    ; TEMPORARY: Set to 0 for testing
    fld TWO                                 ; st(0) = 2
    fmul G_CONSTANT                         ; st(0) = 2*G
    fmul myPlanet.mass                      ; st(0) = 2*G*M
    fild myPlanet.radius                    ; st(0) = r, st(1) = 2*G*M
    fdivr                                   ; st(0) = (2*G*M)/r
    fsqrt                                   ; st(0) = sqrt((2*G*M)/r)
    fstp myPlanet.escapeVelocity
    
                                                                                    ; STEP 6: Calculate Density
                                                                                    ; Formula: d = (3 * M) / (4 * pi * r^3)
                                                                                    ; This is mass/volume where volume = (4/3)*pi*r^3

                                                                                    ; TEMPORARY: Set density to 0 for testing
    fld THREE                               ; st(0) = 3
    fmul myPlanet.mass                      ; st(0) = 3*M
    fld FOUR                                ; st(0) = 4, st(1) = 3*M
    fmul PI                                 ; st(0) = 4*pi, st(1) = 3*M
    fild myPlanet.radius                    ; st(0) = r, st(1) = 4*pi, st(2) = 3*M
    fmul st(0), st(0)                       ; st(0) = r^2
    fmul myPlanet.radius                    ; st(0) = r^3 (approximation)
    fmulp st(1), st(0)                      ; st(0) = 4*pi*r^3, st(1) = 3*M
    fdivr                                   ; st(0) = (3*M)/(4*pi*r^3)
    fstp myPlanet.density
    
                                                                                    ; STEP 7: Display results using printPlanetInfo macro

    call Crlf                                                                       ; Blank line for formatting
    printPlanetInfo offset myPlanet                                                 ; Call macro to print all info
    call Crlf
    
                                                                                    ; STEP 8: Exit program

    mov rdx, offset promptMass                                                      ; Pause message
    call WriteString
    call Crlf
    
    mov rax, 0                                                                      ; Pause - wait for input
    call ReadString
    
    mov rcx, 0                                                                      ; Exit code 0
    call ExitProcess

main endp
end                                                                                 ; End of Line