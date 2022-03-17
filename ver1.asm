; Szilagyi Krisztian-Attila, 514/2, CNN Projekt
;.\nasm -f win32 grafika.asm
;.\nlink grafika.obj -lio -lutil -lgfx -o grafika.exe

%include 'io.inc'
%include 'util.inc'
%include 'gfx.inc'

%define FULLSCREEN 0
%define CURSOR_SIZE 32;16
%define MAX_WIDTH  596;1920;
%define MAX_HEIGHT 448;1080;
%define DRAW_WIDTH  MAX_WIDTH*3/4
%define DRAW_HEIGHT  MAX_HEIGHT

%define BTN_SPACING  30
%define BTN_PADDING  (MAX_WIDTH-DRAW_WIDTH)*1/4

%define BTN_WIDTH_POS1  DRAW_WIDTH+BTN_PADDING
%define BTN_WIDTH_POS2  MAX_WIDTH-BTN_PADDING
%define BTN_WIDTH    BTN_WIDTH_POS2-BTN_WIDTH_POS1

%define BTN_HEIGHT   BTN_PADDING*2/3
%define BTN1_HEIGHT_POS1  BTN_PADDING
%define BTN1_HEIGHT_POS2  BTN1_HEIGHT_POS1+BTN_HEIGHT
%define BTN2_HEIGHT_POS1  BTN1_HEIGHT_POS2+BTN_SPACING
%define BTN2_HEIGHT_POS2  BTN2_HEIGHT_POS1+BTN_HEIGHT


global main

section .text

main:
    mov     eax, str_help1
    call    io_writestr
    call    io_writeln
    mov     eax, str_help2
    call    io_writestr
    call    io_writeln

    mov     eax, MAX_WIDTH
    mov     ebx, MAX_HEIGHT
    mov     ecx, FULLSCREEN
    mov     edx, str_title
    call    gfx_init

    cmp     al, 1
    jne     .nem_ok

    call    GFX

    call    gfx_destroy

    ret

    .nem_ok:
        mov     eax, str_hiba
        call    io_writestr
        call    io_writeln

        ret

;main

;GRAFIKA
GFX:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    edi
    push    esi
    .mainloop:
        call    gfx_map
        mov     dword [map_cim], eax

        .drawloop:
            xor     ebx, ebx
            xor     ecx, ecx
            .yloop:
                cmp     ecx, DRAW_HEIGHT
                jge     .yend
                

                xor     ebx, ebx
                xor     edx, edx
                xor     edi, edi
                .xloop1:
                    cmp     edi, DRAW_WIDTH
                    jge     .xend1

                    mov     [eax], bl
                    mov     [eax+1], bl
                    mov     [eax+2], bl
                    mov     [eax+3], bl

                    add     eax, 4

                    inc     edi
                    jmp     .xloop1
                .xend1:

                mov     ebx, 200
                .xloop2:
                    cmp     edi, MAX_WIDTH
                    jge     .xend2

                    cmp     edi, BTN_WIDTH_POS1
                    jl      .felulet

                    cmp     edi, BTN_WIDTH_POS2
                    jg      .felulet

                    cmp     ecx, BTN1_HEIGHT_POS1
                    jl      .felulet

                    cmp     ecx, BTN1_HEIGHT_POS2
                    jg      .btn2

                    .btn1:
                        mov     [eax], dl
                        mov     [eax+1], bl
                        mov     [eax+2], dl
                        mov     [eax+3], dl
                        jmp     .ok

                    .btn2:
                        cmp     ecx, BTN2_HEIGHT_POS1
                        jl      .felulet

                        cmp     ecx, BTN2_HEIGHT_POS2
                        jg      .felulet

                        mov     [eax], dl
                        mov     [eax+1], dl
                        mov     [eax+2], bl
                        mov     [eax+3], dl
                        jmp     .ok

                    .felulet:
                        mov     [eax], bl
                        mov     [eax+1], bl
                        mov     [eax+2], bl
                        mov     [eax+3], bl
                    .ok:

                    add     eax, 4

                    inc     edi
                    jmp     .xloop2
                .xend2:

                inc     ecx
                jmp     .yloop
            .yend:

            call    gfx_unmap
            call    gfx_draw
        .drawloop_end:

        .eventloop:
            call    gfx_getevent

            cmp     al, 23
            je      .mainloop_end
            cmp     al, 27
            je      .mainloop_end

            cmp     al, 1
            jne     .mouse_end

            .mouse:
                call    gfx_getmouse

                mov     dword [MouseX], eax
                mov     dword [MouseY], ebx

                .btn_go:
                    cmp     eax, BTN_WIDTH_POS1
                    jl      .btn_not_go

                    cmp     eax, BTN_WIDTH_POS2
                    jg      .btn_not_go

                    cmp     ebx, BTN1_HEIGHT_POS1
                    jl      .btn_not_go

                    cmp     ebx, BTN1_HEIGHT_POS2
                    jg      .btn_not_go

                    call    Write_file
                    call    io_writeln
                    call    CNN
                .btn_not_go:

                .btn_delete:
                    cmp     eax, BTN_WIDTH_POS1
                    jl      .btn_not_delete

                    cmp     eax, BTN_WIDTH_POS2
                    jg      .btn_not_delete

                    cmp     ebx, BTN2_HEIGHT_POS1
                    jl      .btn_not_delete

                    cmp     ebx, BTN2_HEIGHT_POS2
                    jg      .btn_not_delete

                    jmp     .mainloop
                .btn_not_delete:

                cmp     eax, DRAW_WIDTH-(CURSOR_SIZE/2)
                jg      .mouse_end
                cmp     ebx, MAX_HEIGHT-(CURSOR_SIZE/2)
                jg      .mouse_end
                cmp     eax, CURSOR_SIZE/2
                jl      .mouse_end
                cmp     ebx, CURSOR_SIZE/2
                jl      .mouse_end

                            .debug:
                                push    eax
                                push    ebx

                                push    eax
                                mov     eax, str_X
                                call    io_writestr
                                pop     eax
                                call    io_writeint

                                mov     eax, str_Y
                                call    io_writestr
                                xchg    eax, ebx
                                call    io_writeint
                                xor     eax, eax

                                mov     eax, str_space
                                call    io_writestr

                                mov     eax, cr
                                call    io_writestr
                                pop     ebx
                                pop     eax
                            .debug_end:

                call    Re_draw

                call    gfx_getevent
                cmp     al, -1
                jne     .mouse
            .mouse_end:

            jmp     .eventloop
        .eventloop_end:
    .mainloop_end:

    pop     esi
    pop     edi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax

    ret

Re_draw:
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    edi

        xor     edx, edx
        xor     edi, edi

        mov     ebx, 255

        mov     ecx, MAX_WIDTH
        mov     edi, dword [MouseY]
            sub     edi, CURSOR_SIZE/2
        imul    edi, 4
        imul    ecx, edi

        mov     edi, dword [MouseX]
            sub     edi, CURSOR_SIZE/2
        imul    edi, 4
        add     ecx, edi

        call    gfx_map
        add     eax, ecx

        mov     ecx, CURSOR_SIZE
        mov     edi, MAX_WIDTH
        imul    edi, 4

        .pixel1:
            push    ecx

            mov     ecx, CURSOR_SIZE
            .pixel2:
                mov     [eax], bl
                mov     [eax+1], bl
                mov     [eax+2], bl
                mov     [eax+3], dl

                add     eax, 4
            loop    .pixel2

            mov     ecx, CURSOR_SIZE
            imul    ecx, 4
            sub     eax, ecx
            add     eax, edi

            pop     ecx
        loop    .pixel1


        call    gfx_unmap
        call    gfx_draw

        pop     edi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax
        ret

Write_file:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    edi
    push    esi

    mov     eax, DRAW_WIDTH*MAX_HEIGHT*4
    push    eax
    call    mem_alloc
    mov     dword [rajz_adat], eax

    call    gfx_map
    push    eax
    call    gfx_unmap
    pop     eax

    xor     ecx, ecx
    mov     edi, dword [rajz_adat]
    .copy_loop:
        mov     esi, eax
        cmp     ecx, MAX_HEIGHT
        jge     .copy_loop_end
        push    ecx
        imul    ecx, MAX_WIDTH*4
        add     esi, ecx
        
        xor     ecx, ecx
        mov     ecx, DRAW_WIDTH
        rep     movsd
        
        pop     ecx

        inc     ecx

        jmp     .copy_loop
    .copy_loop_end:

    mov     eax, file_rajz
    mov     ebx, 1
    call    fio_open
    pop     ecx

    mov     ebx, dword [rajz_adat]

    call    fio_write

    call    fio_close

    mov     eax, dword [rajz_adat]

    call    mem_free

    pop     esi
    pop     edi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax

    ret
;GRAFIKA


;CNN                                ; TO DO: Nullazni minden valtozot
CNN:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

    .nullaz:
        xor     eax, eax
        xor     ebx, ebx
        mov     ebx, 28
        mov     dword [bin_size], eax
        mov     dword [bin_adat], eax
        mov     dword [bin_current], eax
        mov     dword [sorszam], eax
        mov     dword [parameter_cim], eax
        mov     dword [rajz_full], eax
        mov     dword [rajz], eax
        mov     dword [conv_temp], eax
        mov     dword [conv_padded], eax
        mov     dword [conv_filter], eax
        mov     dword [pool_padded], eax
        mov     dword [temp_data], eax
        mov     dword [fc_data], eax
        mov     dword [fc_in], eax
        mov     dword [fc_out], eax
        mov     dword [conv_out], eax
        mov     byte [conv_in], al
        mov     byte [conv_kx], al
        mov     byte [conv_ky], al
        mov     byte [conv_padx], al
        mov     byte [conv_pady], al
        mov     byte [pool_k], al
        mov     byte [pool_str], al
        mov     byte [pool_pad], al
        mov     byte [size], bl
    .nullaz_end:

    call    Beolvas_txt                     ; Csak a .txt-t olvassa be

    call    PreProc                         ; Beolvassa a kepet majd dolgozik vele

    call    Beolvas_bin

    mov     esi, fuggvenyek
    .fuggvenyek:
        xor     eax, eax
        lodsb
        cmp     al, 0                       ; Nincs tobb fuggveny
        je      .fuggvenyek_end
        cmp     al, 1                       ; Conv
        je      .case1
        cmp     al, 2                       ; RelU
        je      .case2
        cmp     al, 3                       ; Pool
        je      .case3
        cmp     al, 4                       ; Fc
        je      .case4
        cmp     al, 5                       ; Softmax
        je      .case5

        jmp     .cases_end                  ; Ha veletlenul nem ismert ertek kerul be, ignoralja

        .case1:
            call    Conv
            jmp     .cases_end

        .case2:
            call    RelU
            jmp     .cases_end

        .case3:
            call    Pool
            jmp     .cases_end

        .case4:
            call    Fc
            jmp     .cases_end

        .case5:
            call    Softmax
            jmp     .cases_end

        .cases_end:

        inc     byte [sorszam]

        jmp     .fuggvenyek
    .fuggvenyek_end:

    mov     eax, dword [rajz]
    call    mem_free

    mov     eax, dword [fc_data]
    call    mem_free

    mov     eax, dword [fc_out]
    call    mem_free

    mov     eax, dword [temp_data]
    call    mem_free

    mov     eax, dword [parameter_cim]
    call    mem_free

    mov     eax, dword [bin_adat]
    call    mem_free

    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

PreProc:                                    ; Gyorsitani kell dik, valamint nem jo (mean == 0, std == 1 kell)
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

    ;mov     eax, str_pre
    ;call    io_writestr
    ;call    io_writeln

    .read:
        mov     eax, DRAW_WIDTH*DRAW_HEIGHT
        imul    eax, 4
        call    mem_alloc
        mov     dword [rajz_full], eax                  ; Ezt majd fel kell szabaditani

        mov     eax, rajz_bin
        mov     ebx, 0
        call    fio_open
        push    eax

        mov     ebx, dword [rajz_full]
        mov     ecx, DRAW_WIDTH*DRAW_HEIGHT
        imul    ecx, 4
        call    fio_read

        pop     eax
        call    fio_close
    .read_end:

    .allocate:
        mov     eax, 784*4                    ; 28*28*4 = 3136 byte-nyi hely
        call    mem_alloc
        mov     dword [rajz], eax
        mov     edi, dword [rajz]
    .allocate_end:

    .resize:    ; 28x28 db, 16x16 pixelbol allo blokkok
        xor     ecx, ecx
        .yloop1:                                ; Ez bejarja a kep sorait, 28 db
            cmp     ecx, 28
            jge     .yloop1_end

            push    ecx
            mov     esi, dword [rajz_full]              ; Honnan olvasson
            imul    ecx, DRAW_WIDTH*16*4                ; Minden uj olvasas 16 sorral az elozo utan fog kezdodni
            add     esi, ecx
            pop     ecx

            push    ecx
            xor     ecx, ecx
            .xloop1:                           ; Ez bejarja a kep oszlopait, 28 db
                cmp     ecx, 28
                jge     .xloop1_end
                push    ecx
                push    esi

                xor     ecx, ecx
                xor     ebx, ebx
                .yloop2:                       ; Ez bejarja a keptomb sorait, 16 db
                    cmp     ecx, 16            ; 4 * (448 / 28) = 4 * 16 = 64
                    jge     .yloop2_end

                    pop     esi
                    push    esi

                    push    ecx
                    imul    ecx, DRAW_WIDTH*4   ; Kovetkezo sorra lep a keptombben
                    add     esi, ecx
                    pop     ecx

                    push    ecx
                    xor     ecx, ecx
                    .xloop2:                  ; Ez bejarja a keptomb oszlopait, 16 db
                        cmp     ecx, 16
                        jge     .xloop2_end

                        push    eax
                        xor     eax, eax
                        lodsd;lodsb                 ; Betolt egy byte-ot
                        add     ebx, eax      ; Ossze adom a betoltott ertekeket atlag szamitasra
                        pop     eax

                        ;add     esi, 3        ; Kovetkezo pixelre megy a keptombben

                        inc     ecx

                        jmp     .xloop2
                    .xloop2_end:
                    pop     ecx

                    inc     ecx

                    jmp     .yloop2
                .yloop2_end: ;///////////////////////////////////////////////////////
                pop     esi
                pop     ecx

                inc     ecx

                add     esi, 64         ; A kovetkezo keptomb elejere lep, az elso oszlopra

                .avg:
                    push    eax
                    mov     eax, ebx
                    mov     ebx, 256    ; 16*16 = 256
                    xor     edx, edx
                    idiv    ebx         ; Atlag szamitas
                    stosd
                    pop     eax
                .avg_end:

                jmp     .xloop1
            .xloop1_end:
            pop     ecx

            inc     ecx

            jmp     .yloop1
        .yloop1_end:
    .resize_end:

    ;call    VISUALIZE

    mov     eax, 0xFFFFFF
    cvtsi2ss    xmm1, eax
    movss       xmm2, [const_mean]
    movss       xmm3, [const_std]
    mov         esi, dword [rajz]
    mov         edi, dword [rajz]
    xor         ecx, ecx
    .scale:
        cmp     ecx, 784
        jge     .scale_end

        lodsd
        cvtsi2ss    xmm0, eax

        divss       xmm0, xmm1  ; scale to [0,1]
        subss       xmm0, xmm2  ; mean
        divss       xmm0, xmm3  ; std

        movd        eax, xmm0
        stosd

        inc     ecx

        jmp     .scale
    .scale_end:

    ;call    VISUALIZE

    mov     eax, dword [rajz_full]
    call    mem_free


    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

Beolvas_txt:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

    .net:
        mov     eax, net_txt
        xor     ebx, ebx                ; read
        call    fio_open
        push    eax

        mov     ebx, adat               ; hova olvasson
        mov     ecx, 1024               ; mennyit olvasson (byte)
        call    fio_read

        mov     esi, adat
        call    fio_close

        xor     edx, edx
        .fuggvenyek:                    ; fuggvenyek szamanak es sorrendjenek meghatarozas
            xor     eax, eax
            lodsb
            cmp     al, 0
            je      .fuggvenyek_end
            cmp     al, ':'
            jne     .fuggvenyek
            push    esi
            std
            xor     ecx, ecx

            .check_fgv:
                xor     eax, eax
                lodsb
                cmp     al, ':'
                je      .check_fgv
                cmp     al, ')'
                je      .check_fgv
                cmp     al, '('
                je      .check_fgv_end
                cmp     al, '9'
                jle     .check_fgv

                push    eax
                inc     ecx

                jmp     .check_fgv
            .check_fgv_end:
            mov     edi, temp_bss
            cld
            mov     ebx, ecx
            .get1:
                pop     eax
                stosb
            loop    .get1
            mov     ecx, ebx

            .azonosit:
                push    ecx
                .conv:
                    mov     esi, temp_bss
                    mov     edi, str_conv
                    repe    cmpsb
                    jnz     .conv_end
                    mov     edi, fuggvenyek
                    add     edi, edx
                    inc     edx
                    mov     eax, 1
                    stosb
                .conv_end:
                pop     ecx

                push    ecx
                .relu:
                    mov     esi, temp_bss
                    mov     edi, str_relu
                    repe    cmpsb
                    jnz     .relu_end
                    mov     edi, fuggvenyek
                    add     edi, edx
                    inc     edx
                    mov     eax, 2
                    stosb
                .relu_end:
                pop     ecx

                push    ecx
                .pool:
                    mov     esi, temp_bss
                    mov     edi, str_pool
                    repe    cmpsb
                    jnz     .pool_end
                    mov     edi, fuggvenyek
                    add     edi, edx
                    inc     edx
                    mov     eax, 3
                    stosb
                .pool_end:
                pop     ecx

                push    ecx
                .fc:
                    mov     esi, temp_bss
                    mov     edi, str_fc
                    repe    cmpsb
                    jnz     .fc_end
                    mov     edi, fuggvenyek
                    add     edi, edx
                    inc     edx
                    mov     eax, 4
                    stosb
                .fc_end:
                pop     ecx

                push    ecx
                .softmax:
                    mov     esi, temp_bss
                    mov     edi, str_softmax
                    repe    cmpsb
                    jnz     .softmax_end
                    mov     edi, fuggvenyek
                    add     edi, edx
                    inc     edx
                    mov     eax, 5
                    stosb
                .softmax_end:
                pop     ecx

            .azonosit_end:
            pop     esi

            jmp     .fuggvenyek
        .fuggvenyek_end:

        .foglalas:                      ; minden fuggvenynek foglal egy dword-nyi helyet a parameter cimeknek
            push    eax
            push    edx
            mov     eax, edx
            imul    eax, 4
            call    mem_alloc

            mov     dword [parameter_cim], eax
            mov     eax, dword [parameter_cim]
            pop     edx
            pop     eax

        mov     esi, adat
        .clear:                         ; csak a szukseges szamok maradnak meg, minden mast ',' karakterre alakit
            xor     eax, eax
            lodsb

            cmp     al, 0
            je      .clear_end

            cmp     al, 'T'
            je      .TF

            cmp     al, 'F'
            je      .TF

            cmp     al, ':'
            je      .feles

            cmp     al, '('
            je      .feles

            cmp     al, ','
            je      .clear

            cmp     al, '0'
            jge     .szam

                mov     eax, ','
                push    edi
                mov     edi, esi
                dec     edi
                stosb
                pop     edi

            jmp     .clear
            .szam:
                cmp     al, '9'
                jle     .clear

                mov     eax, ','
                push    edi
                mov     edi, esi
                dec     edi
                stosb
                pop     edi

                jmp     .clear
        .clear_end:

        mov     esi, fuggvenyek
        xor     ebx, ebx
        xor     ecx, ecx
        xor     edx, edx

        .parameterek:
            xor     eax, eax
            lodsb
            cmp     al, 0
            je      .parameterek_end

            push    esi

            cmp     al, 1
            je      .case1
            cmp     al, 2
            je      .case2
            cmp     al, 3
            je      .case3
            cmp     al, 4
            je      .case4
            cmp     al, 5
            je      .case5

                .case1:                                     ; conv
                    push    eax

                    mov     eax, 16*8                       ; helyfoglalas
                    call    mem_alloc

                    mov     edi, dword [parameter_cim]      ; lefoglalt hely cimenek mentese
                    add     edi, edx
                    stosd
                    add     edx, 4

                    xor     ebx, ebx
                    mov     ecx, 8
                    mov     esi, adat
                    .conv_read:
                        xor     eax, eax
                        lodsb

                        cmp     al, 0
                        je      .conv_read_end

                        cmp     al, ','
                        je      .conv_read

                        call    .converter

                        push    edi
                        push    eax
                        mov     eax, edi
                        sub     eax, 4
                        mov     edi, dword [eax]
                        pop     eax
                        add     edi, ebx
                        add     ebx, 4
                        stosd
                        pop     edi

                        loop     .conv_read
                    .conv_read_end:

                    pop     eax

                    jmp     .cases_end
                .case1_end:

                .case2:                                     ; relu
                    push    eax
                    mov     eax, 16*1
                    call    mem_alloc

                    mov     edi, dword [parameter_cim]
                    add     edi, edx
                    stosd
                    add     edx, 4

                    mov     eax, edi                        ; "filler" ertek
                    sub     eax, 4
                    mov     edi, dword [eax]
                    mov     eax, 0xFFFFFFFF
                    stosd

                    pop     eax

                    jmp     .cases_end
                .case2_end:

                .case3:                                     ; pool
                    push    eax
                    mov     eax, 16*5
                    call    mem_alloc

                    mov     edi, dword [parameter_cim]
                    add     edi, edx
                    stosd
                    add     edx, 4

                    xor     ebx, ebx
                    mov     ecx, 5
                    mov     esi, adat
                    .pool_read:
                        xor     eax, eax
                        lodsb

                        cmp     al, 0
                        je      .pool_read_end

                        cmp     al, ','
                        je      .pool_read

                        call    .converter

                        push    edi
                        push    eax
                        mov     eax, edi
                        sub     eax, 4
                        mov     edi, dword [eax]
                        pop     eax
                        add     edi, ebx
                        add     ebx, 4
                        stosd
                        pop     edi

                        loop     .pool_read
                    .pool_read_end:

                    pop     eax

                    jmp     .cases_end
                .case3_end:

                .case4:                                     ; fc
                    push    eax
                    mov     eax, 16*3
                    call    mem_alloc

                    mov     edi, dword [parameter_cim]
                    add     edi, edx
                    stosd
                    add     edx, 4

                    xor     ebx, ebx
                    mov     ecx, 3
                    mov     esi, adat
                    .fc_read:
                        xor     eax, eax
                        lodsb

                        cmp     al, 0
                        je      .fc_read_end

                        cmp     al, ','
                        je      .fc_read

                        call    .converter

                        push    edi
                        push    eax
                        mov     eax, edi
                        sub     eax, 4
                        mov     edi, dword [eax]
                        pop     eax
                        add     edi, ebx
                        add     ebx, 4
                        stosd
                        pop     edi

                        loop     .fc_read
                    .fc_read_end:

                    pop     eax

                    jmp     .cases_end
                .case4_end:

                .case5:                                     ; softmax
                    push    eax
                    mov     eax, 16*1
                    call    mem_alloc

                    mov     edi, dword [parameter_cim]
                    add     edi, edx
                    stosd
                    add     edx, 4

                    xor     ebx, ebx
                    mov     ecx, 1
                    mov     esi, adat
                    .softmax_read:
                        xor     eax, eax
                        lodsb

                        cmp     al, 0
                        je      .softmax_read_end

                        cmp     al, ','
                        je      .softmax_read

                        call    .converter

                        push    edi
                        push    eax
                        mov     eax, edi
                        sub     eax, 4
                        mov     edi, dword [eax]
                        pop     eax
                        add     edi, ebx
                        add     ebx, 4
                        stosd
                        pop     edi

                        loop     .softmax_read
                    .softmax_read_end:

                    pop     eax

                    jmp     .cases_end
                .case5_end:

                .cases_end:

            pop     esi
            jmp     .parameterek
        .parameterek_end:

        pop     eax
        call    fio_close
    .net_end:

    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

    .TF:
        cmp     al, 'T'
        je      .true
        cmp     al, 'F'
        je      .false
        .TF_back:
        push    edi
        mov     edi, esi
        dec     edi
        stosb
        pop     edi
        jmp     .clear
        .true:
            mov     al, '1'
            jmp     .TF_back
        .false:
            mov     al, '0'
            jmp     .TF_back

    .feles:
        push    edi
        mov     eax, ','
        mov     edi, esi
        dec     edi
        stosb
        dec     edi
        sub     edi, 2
        sub     esi, 2
        stosb
        pop     edi
        
        jmp     .clear

    .converter:
        push    ebx
        push    edi
        xor     ebx, ebx

        sub     eax, '0'
        mov     ebx, eax
        .build:
            mov     edi, esi
            dec     edi
            mov     eax, ','
            stosb

            xor     eax, eax
            lodsb
            cmp     al, ','
            je      .build_end
            sub     eax, '0'
            imul    ebx, 10
            add     ebx, eax
            jmp     .build
        .build_end:

        mov     eax, ebx
        pop     edi
        pop     ebx

        ret

Beolvas_bin:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

    mov     esi, fuggvenyek
    .size_calc:
        xor     ebx, ebx
        .sorrend:
            xor     eax, eax
            lodsb
            inc     dword [sorszam]
            cmp     eax, 0
            je      .size_calc_end
            cmp     eax, 1
            je      .sorrend_end
            cmp     eax, 2
            je      .sorrend
            cmp     eax, 3
            je      .sorrend
            cmp     eax, 4
            je      .sorrend_end
            cmp     eax, 5
            jge     .sorrend

            jmp     .sorrend
        .sorrend_end:
        mov     ebx, eax
        mov     eax, dword [parameter_cim]          ; Megkapjuk a cimekre mutato cimet

        cmp     ebx, 1
        je      .conv
        cmp     ebx, 4
        je      .fc

        .conv:
            xor     ecx, ecx
            xor     edx, edx
            mov     ecx, dword [sorszam]                            ; Fuggveny sorszama
            dec     ecx
            mov     ebx, [eax + 4*ecx]                  ; Megkapunk egy cimet
            mov     eax, ebx

            xor     ecx, ecx
            mov     ebx, [eax + 4*ecx]                  ; in
            add     edx, ebx

            inc     ecx
            mov     ebx, [eax + 4*ecx]                  ; out
            imul    edx, ebx

            inc     ecx
            mov     ebx, [eax + 4*ecx]                  ; kx
            imul    edx, ebx

            inc     ecx
            mov     ebx, [eax + 4*ecx]                  ; ky
            imul    edx, ebx

            mov     ecx, 1
            mov     ebx, [eax + 4*ecx]                  ; bias
            add     edx, ebx

            add     dword [bin_size], edx
            jmp     .fc_end
        .conv_end:

        .fc:
            xor     ecx, ecx
            xor     edx, edx
            mov     ecx, dword [sorszam]                            ; Fuggveny sorszama
            dec     ecx
            mov     ebx, [eax + 4*ecx]                  ; Megkapunk egy cimet
            mov     eax, ebx

            xor     ecx, ecx
            mov     ecx, 0
            mov     ebx, [eax + 4*ecx]                  ; in
            add     edx, ebx

            inc     ecx
            mov     ebx, [eax + 4*ecx]                  ; out
            imul    edx, ebx

            mov     ecx, 1
            mov     ebx, [eax + 4*ecx]                  ; bias
            add     edx, ebx
            
            add     dword [bin_size], edx
            jmp     .fc_end
        .fc_end:
        jmp     .size_calc
    .size_calc_end:

    mov     eax, dword [bin_size]
    imul    eax, 4
    mov     dword [bin_size], eax

    call    mem_alloc
    mov     dword [bin_adat], eax

    mov     eax, net_bin                    ; Binaris fajl megnyitas
    mov     ebx, 0
    call    fio_open
    push    eax
    
    mov     ebx, dword [bin_adat]
    mov     ecx, dword [bin_size]
    call    fio_read
    ;mov     eax, edx
    ;call    io_writeint
    ;call    io_writeln

    pop     eax
    call    fio_close

    mov     eax, dword [bin_adat]
    mov     dword [bin_current], eax
    mov     dword [sorszam], 0

    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret
Conv:                                       ; Valoszinuleg hibas
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

    ;mov     eax, str_conv
    ;call    io_writestr
    ;call    io_writeln

    .parameterek:
        mov     eax, dword [parameter_cim]

        xor     ecx, ecx
        mov     cl, byte [sorszam]                              ; Fuggveny sorszama
        mov     ebx, [eax + 4*ecx]
        mov     eax, ebx

        xor     ebx, ebx
        mov     ebx, [eax]
        mov     byte [conv_in], bl

        add     eax, 4
        xor     ebx, ebx
        mov     ebx, [eax]
        mov     byte [conv_out], bl

        add     eax, 4
        xor     ebx, ebx
        mov     ebx, [eax]
        mov     byte [conv_kx], bl

        add     eax, 4
        xor     ebx, ebx
        mov     ebx, [eax]
        mov     byte [conv_ky], bl

        add     eax, 12
        xor     ebx, ebx
        mov     ebx, [eax]
        mov     byte [conv_padx], bl

        add     eax, 4
        xor     ebx, ebx
        mov     ebx, [eax]
        mov     byte [conv_pady], bl
    .parameterek_end:

    ; foglalas meret*meret*kimenet*4 meretre, temp_data cim
    .allocate:
        push    eax
        push    ebx
        xor     eax, eax                    ; temp_data foglalas
        xor     ebx, ebx
        mov     al, byte [size]                 ; 28
            ;mov     bl, byte [conv_kx]
            ;sub     eax, ebx
            ;mov     bl, byte [conv_padx]
            ;imul    ebx, 2
            ;add     eax, ebx
            ;add     eax, 1                  ; size = (old_size - kernel + 2*pad) / stride + 1    ; 26 = (28 - 3 + 2*0) / 1 + 1
            ;mov     byte [size], al
        imul    eax, eax
        mov     bl, byte [conv_out]
        imul    eax, ebx
        imul    eax, 4
        call    mem_alloc
        mov     dword [temp_data], eax

        xor     eax, eax                    ; conv_filter foglalas
        xor     ebx, ebx
        mov     al, byte [conv_ky]
        mov     bl, byte [conv_kx]
        imul    eax, ebx
        imul    eax, 4
        call    mem_alloc
        mov     dword [conv_filter], eax
        pop     ebx
        pop     eax
    .allocate_end:

    call    .clear

    mov     edi, dword [temp_data]                  ; Ide akarom rakni
    xor     ecx, ecx
    .out_loop:
        cmp     ecx, dword [conv_out]                                       ; Kimenetek szama
        jge     .out_loop_end

        ; lekerjuk a filter ertekeit, beallitodik a conv_filter 
        call    .getfilter

        push    ecx
        xor     edx, edx
        .in_loop:
            cmp     dl, byte [conv_in]                                      ; Bemenetek szama
            jge     .in_loop_end

            ; kep betolt rajz-bol
            call    .padding
            ; itt visszajon a modositott kep cime, mint conv_padded

                mov     ebx, dword [conv_padded]                                    ; Innen akarom rakni
                mov     dword [conv_temp], ebx
            push    edx
            xor     eax, eax
            xor     ebx, ebx
            xor     ecx, ecx
            .yloop_img:                                                             ; Adott kep/matrix oszlopai
                cmp     al, byte [size]
                jge     .yloop_img_end

                xor     edx, edx
                xor     ebx, ebx
                .xloop_img:                                                         ; Adott kep/matrix sorai
                    cmp     bl, byte [size]
                    jge     .xloop_img_end

                    mov     esi, dword [conv_filter]

                    xor     ecx, ecx
                    xorps   xmm0, xmm0
                    xorps   xmm7, xmm7
                    .yloop_flr:
                        cmp     cl, byte [conv_ky]
                        jge     .yloop_flr_end

                        push    ecx
                        xor     edx, edx
                        .xloop_flr:
                            cmp     dl, byte [conv_kx]
                            jge     .xloop_flr_end

                            call    .calculate                                      ; xmm7-be kiszamolja adott filtermuvelet eredmenyet

                            inc     dl
                            jmp     .xloop_flr
                        .xloop_flr_end:

                        call    .set1

                        pop     ecx
                        inc     cl
                        jmp     .yloop_flr
                    .yloop_flr_end:

                    call    .set2

                    push    eax
                    push    eax
                    movd    eax, xmm7
                    stosd                                               ; temp_data-ra
                    pop     eax
                    pop     eax

                    inc     bl
                    jmp     .xloop_img
                .xloop_img_end:

                push    eax
                push    ebx
                xor     eax, eax
                mov     al, byte [conv_padx]
                mov     ebx, dword [conv_temp]
                imul    eax, 2
                imul    eax, 4
                add     ebx, eax
                mov     dword [conv_temp], ebx
                pop     ebx
                pop     eax

                inc     al
                jmp     .yloop_img
            .yloop_img_end:

            push    eax
            mov     eax, dword [conv_padded]
            call    mem_free
            pop     eax

            pop     edx
            inc     edx
            jmp     .in_loop
        .in_loop_end:

        pop     ecx
        inc     ecx
        jmp     .out_loop
    .out_loop_end:

    .sum:                           ; Tobb input eseten
    .sum_end:

    .bias:
        mov     esi, dword [temp_data]
        mov     edi, dword [temp_data]

        xor     ebx, ebx
        mov     bl, byte [conv_out]             ; Hany filterem/biasom van

        xor     eax, eax
        xor     edx, edx
        mov     al, byte [size]
        imul    eax, eax
        mov     edx, eax                        ; Hany szamra kell alkalmazzam az adott biast

        xor     ecx, ecx
        .bias_loop:
            cmp     ecx, ebx
            jge     .bias_loop_end

            xor     eax, eax
            xorps   xmm7, xmm7

            push    esi
            mov     esi, dword [bin_current]
            lodsd
            mov     dword [bin_current], esi
            pop     esi
            movd    xmm7, eax                   ; Adott filter bias

            push    ecx
            xor     ecx, ecx
            .bias_sum_loop:
                cmp     ecx, edx
                jge     .bias_sum_loop_end

                xorps   xmm0, xmm0
                lodsd
                movd    xmm0, eax
                addss   xmm0, xmm7
                movd    eax, xmm0
                stosd

                inc     ecx
                jmp     .bias_sum_loop
            .bias_sum_loop_end:
            pop     ecx

            inc     ecx
            jmp     .bias_loop
        .bias_loop_end:
    .bias_end:

    mov     eax, dword [rajz]
    call    mem_free

    mov     eax, dword [conv_filter]
    call    mem_free

    mov     eax, dword [temp_data]
    mov     dword [rajz], eax

    ;call    VISUALIZE2

    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret


    .clear:
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    edi
        
        xor     ebx, ebx
        xor     ecx, ecx
        mov     bl, byte [size]
        imul    ebx, ebx
        mov     cl, byte [conv_out]
        imul    ebx, ecx

        mov     edi, dword [temp_data]
        xor     eax, eax
        xor     ecx, ecx
        .clear_loop:
            cmp     ecx, ebx
            jge     .clear_loop_end

            stosd

            inc     ecx
            jmp     .clear_loop
        .clear_loop_end:

        pop     edi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax
        ret

    .clear_padded:
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    edi

        mov     edi, dword [conv_padded]
        xor     eax, eax
        mov     ebx, esi
        xor     ecx, ecx
        .clear_padded_loop:
            cmp     ecx, ebx
            jge     .clear_padded_loop_end

            stosd

            inc     ecx
            jmp     .clear_padded_loop
        .clear_padded_loop_end:
        pop     edi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax
        ret

    .set1:
        push    eax
        push    ebx
        push    ecx

        mov     ebx, dword [conv_temp]
    
        ; ebx - filterx*4     ; visszamegy kezdo pixelre az adott kepreszlet adott soraban
        xor     eax, eax
        mov     al, byte [conv_kx]
        imul    eax, 4
        sub     ebx, eax
        ; ebx + size*4   ; a kovetkezo sorra megy az adott kepreszletben
        xor     eax, eax
        xor     ecx, ecx
        mov     al, byte [size]
        mov     cl, byte [conv_padx]
        imul    ecx, 2
        add     eax, ecx
        imul    eax, 4
        add     ebx, eax

        mov     dword [conv_temp], ebx

        pop     ecx
        pop     ebx
        pop     eax
        ret

    .set2:
        push    eax
        push    ebx
        push    ecx

        mov     ebx, dword [conv_temp]

        ; ebx - filtery*size*4  ; visszamegy kezdo pixelre az adott kepreszlet adott oszlopaban
        push    ebx
        xor     eax, eax
        xor     ebx, ebx
        xor     ecx, ecx
        mov     al, byte [conv_ky]
        mov     bl, byte [size]
        mov     cl, byte [conv_pady]
        imul    ecx, 2
        add     ebx, ecx
        imul    eax, ebx
        pop     ebx
        imul    eax, 4
        sub     ebx, eax
        ; ebx + filterx*4            ; a kovetkezo conv_kx. oszlopra megy, lehetoleg uj kepreszlet elso pixelere
        add     ebx, 4

        mov     dword [conv_temp], ebx

        pop     ecx
        pop     ebx
        pop     eax
        ret



    .calculate:
        push    eax
        push    ebx

        mov     ebx, dword [conv_temp]

        lodsd                           ; 1. szam, filter
        movd    xmm0, eax

        push    esi                     ; 2. szam, kep
        xchg    esi, ebx
        lodsd
        xchg    esi, ebx
        pop     esi

        movd    xmm1, eax
        mulss   xmm0, xmm1
        addss   xmm7, xmm0

        mov     dword [conv_temp], ebx

        pop     ebx
        pop     eax
        ret

    .padding:
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        push    edx                  ; ESI eltolas
        xor     eax, eax
        xor     ebx, ebx
        mov     al, byte [size]
        mov     bl, byte [conv_padx]
        imul    ebx, 2
        add     eax, ebx            ; 28 + 2pad
        mov     ebx, eax            ; 30
        imul    eax, eax            ; 30 * 30
        mov     esi, eax            ; clear
        imul    eax, 4
        call    mem_alloc
        mov     dword [conv_padded], eax

        call    .clear_padded

        mov     eax, ebx                ; 30
        sub     al, byte [conv_padx]    ; (28 + 2pad) - pad
        pop     edx                     ; ESI eltolas

        mov     esi, dword [rajz]
        mov     edi, dword [conv_padded]

        push    eax
        push    ebx
        .esi_offset:
            xor     eax, eax
            xor     ebx, ebx
            mov     al, byte [size]
            mov     bl, byte [conv_in]
            imul    eax, eax
            imul    eax, ebx
            imul    eax, 4      ; Eltolas merete

            imul    eax, edx    ; Hanyat toljuk el

            add     esi, eax
        .esi_offset_end:
        pop     ebx
        pop     eax

        xor     ecx, ecx
        .yloop_pad:
            cmp     ecx, ebx            ; 30
            jge     .yloop_pad_end

            xor     edx, edx
            .xloop_pad:
                cmp     edx, ebx        ; 30
                jge     .xloop_pad_end

                ; if(conv_pad != 0 && ((y < pad || y >= size-pad) || (x < pad || x >= size-pad))) stosd 0; else stosd;
                cmp     byte [conv_pady], 0
                jne     .pady

                push    eax
                lodsd
                stosd
                pop     eax

                .pad_back:
                inc     edx
                jmp     .xloop_pad
            .xloop_pad_end:
            inc     ecx
            jmp     .yloop_pad
        .yloop_pad_end:

        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax
        ret

        .pady:
            cmp     ecx, eax    ; Ha meg nem ertunk a vegere
            jl      .pady2
            
            .pady_back:         ; 0-t tarolunk
            push    eax
            xor     eax, eax
            stosd
            pop     eax
            jmp     .pad_back

            .pady2:
                cmp     cl, byte [conv_pady]
                jl      .pady_back              ; Ha paddingen vagyunk
                jmp     .padx                   ; Kulonben kepben vagyunk

        .padx:
            cmp     edx, eax        ; Ha meg nem ertunk a vegere
            jl      .padx2
            
            .padx_back:             ; 0-t tarolunk
            push    eax
            xor     eax, eax
            stosd
            pop     eax
            jmp     .pad_back

            .padx2:
                cmp     dl, byte [conv_padx]
                jl      .padx_back              ; Ha paddingen vagyunk
                push    eax                     ; Kulonben taroljuk a kep erteket
                lodsd
                stosd
                pop     eax
                jmp     .pad_back

    .getfilter:
        push    eax
        push    ebx
        push    ecx
        push    esi
        push    edi

        mov     esi, dword [bin_current]
        mov     edi, dword [conv_filter]
        xor     ecx, ecx
        .yloop:
            cmp     cl, byte [conv_ky]
            jge     .yloop_end

            push    ecx
            xor     ecx, ecx
            .xloop:
                cmp     cl, byte [conv_kx]
                jge     .xloop_end

                xor     eax, eax
                lodsd
                stosd

                inc     ecx

                jmp     .xloop
            .xloop_end:
            pop     ecx
            inc     ecx
            jmp     .yloop
        .yloop_end:

        mov     dword [bin_current], esi

        pop     edi
        pop     esi
        pop     ecx
        pop     ebx
        pop     eax
        ret

RelU:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

    ;mov     eax, str_relu
    ;call    io_writestr
    ;call    io_writeln

    xor     eax, eax
    mov     eax, dword [conv_out]

    mov     esi, dword [rajz]
    mov     edi, dword [rajz]

    xor     ebx, ebx
    .loop:
        cmp     ebx, eax
        jge     .loop_end

        push    eax

        lodsd
        movd    xmm0, eax
        xor     eax, eax
        cvtsi2ss    xmm1, eax
        maxss   xmm0, xmm1
        movd    eax, xmm0
        stosd

        pop     eax

        inc     ebx
        jmp     .loop
    .loop_end:

    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

Pool:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

    ;mov     eax, str_pool
    ;call    io_writestr
    ;call    io_writeln

    .parameterek:
        mov     eax, dword [parameter_cim]

        xor     ecx, ecx
        mov     cl, byte [sorszam]                              ; Fuggveny sorszama
        mov     ebx, [eax + 4*ecx]
        mov     eax, ebx

        xor     ebx, ebx
        mov     ebx, [eax]
        mov     byte [pool_k], bl

        add     eax, 4
        xor     ebx, ebx
        mov     ebx, [eax]
        mov     byte [pool_str], bl

        add     eax, 4
        xor     ebx, ebx
        mov     ebx, [eax]
        mov     byte [pool_pad], bl
    .parameterek_end:

    ; meret = (meret + 2pad) / 2
    .size:
        xor     eax, eax
        xor     ebx, ebx
        mov     al, byte [size]         ; 28
        mov     bl, byte [pool_pad]     ; 0
        imul    ebx, 2                  ; 0
        add     eax, ebx                ; 28 + 0
        mov     ebx, 2
        div     bl                      ; 28 / 2
        mov     byte [size], al         ; 14
    .size_end:

    .allocate:
        push    eax
        push    ebx
        xor     eax, eax                    ; temp_data foglalas
        xor     ebx, ebx
        mov     al, byte [size]
        imul    eax, eax
        mov     bl, byte [conv_out]
        imul    eax, ebx
        imul    eax, 4
        call    mem_alloc                   ; size * size * out * 4 ( == 14 * 14 * 16 * 4) byte
        mov     dword [temp_data], eax

        xor     eax, eax                    ; pool_padded foglalas
        xor     ebx, ebx
        mov     al, byte [size]             ; pool meret
        imul    eax, 2
        mov     bl, byte [pool_pad]
        imul    ebx, 2
        sub     eax, ebx
        xor     ebx, ebx                    ; Eredeti meret
        imul    eax, eax
        imul    eax, 4
        call    mem_alloc                   ; o_size * o_size * 4 ( == 28 * 28 * 4) byte
        mov     dword [pool_padded], eax
        pop     ebx
        pop     eax
    .allocate_end:

    mov     edi, dword [temp_data]                                  ; Ide akarom rakni
    xor     ecx, ecx
    .loop:
        cmp     cl, byte [conv_out]                                 ; Ahany kepunk van, mindre elvegezzuk
        jge     .loop_end

        ; Kep betoltese, majd padding beallitas, ha van
        call    .padding

        mov     esi, dword [pool_padded]                            ; Innen

        push    ecx
        xor     ecx, ecx
        xor     edx, edx
        .yloop_img: ; ez jonak tunik                                ; kep sorai
            cmp     ch, byte [size] ; 14
            jge     .yloop_img_end
            push    ecx

            xor     edx, edx
            .xloop_img:                                             ; kep oszlopai
                cmp     dh, byte [size] ; 14
                jge     .xloop_img_end
                push    edx

                xor     ecx, ecx
                xorps   xmm0, xmm0
                xorps   xmm7, xmm7
                .yloop2:                                            ; "filter" sorai
                    cmp     cl, byte [pool_k]
                    jge     .yloop2_end

                    push    ecx
                    xor     edx, edx
                    .xloop2:                                        ; "filter" oszlopai
                        cmp     dl, byte [pool_k]
                        jge     .xloop2_end

                        call    .calculate

                        inc     dl
                        jmp     .xloop2
                    .xloop2_end:

                    call    .set1

                    pop     ecx
                    inc     cl
                    jmp     .yloop2
                .yloop2_end:

                call    .set2

                xor     eax, eax
                movd    eax, xmm7
                stosd

                pop     edx
                inc     dh
                jmp     .xloop_img
            .xloop_img_end:
            pop     ecx

                push    eax
                xor     eax, eax
                mov     al, byte [size] ; 14
                imul    eax, 2          ; 28
                ;+pad
                imul    eax, 4
                add     esi, eax
                pop     eax

            inc     ch
            jmp     .yloop_img
        .yloop_img_end:
        pop     ecx

        inc     ecx
        jmp     .loop
    .loop_end:

    mov     eax, dword [rajz]
    call    mem_free

    mov     eax, dword [pool_padded]
    call    mem_free

    mov     eax, dword [temp_data]
    mov     dword [rajz], eax

    ;call    VISUALIZE3

    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

    .calculate:
        xor     eax, eax
        xorps   xmm0, xmm0
        lodsd
        movd    xmm0, eax
        maxss   xmm7, xmm0
        ret

    .set1:
        push    eax
        push    ebx

        ; esi - kernel*4     ; visszamegy kezdo pixelre az adott kepreszlet adott soraban
        xor     eax, eax
        mov     al, byte [pool_k]   ; 2
        imul    eax, 4
        sub     esi, eax
        ; esi + size*4   ; a kovetkezo sorra megy az adott kepreszletben
        xor     eax, eax
        xor     ebx, ebx
        mov     al, byte [size]     ; 14
        mov     bl, byte [pool_pad] ; 0
        imul    eax, 2              ; 28
        imul    ebx, 2              ; 0
        sub     eax, ebx            ; 28 ; eredeti
        imul    eax, 4              ; 28 * 4
        add     esi, eax

        pop     ebx
        pop     eax
        ret

    .set2:
        ; esi - kernel*size*4  ; visszamegy kezdo pixelre az adott kepreszlet adott oszlopaban
        xor     eax, eax
        xor     ebx, ebx
        mov     al, byte [size]     ; 14
        mov     bl, byte [pool_pad] ; 0
        imul    eax, 2              ; 28
        imul    ebx, 2              ; 0
        sub     eax, ebx            ; 28 ; eredeti

        xor     ebx, ebx
        mov     bl, byte [pool_k]   ; 2
        imul    eax, ebx            ; 56
        imul    eax, 4              ; 56 * 4
        sub     esi, eax
        ; esi + kernel*4            ; a kovetkezo pool_k. oszlopra megy, lehetoleg uj kepreszlet elso pixelere
        xor     eax, eax
        mov     al, byte [pool_k]   ; 2
        imul    eax, 4
        add     esi, eax
        ret

    .padding:
        push    eax
        push    ecx
        push    edx
        push    esi
        push    edi

        .origin_size:
            xor     eax, eax
            xor     ebx, ebx
            mov     al, byte [size]         ; 14
            imul    eax, 2                  ; 28
            mov     bl, byte [pool_pad]     ; 0
            imul    ebx, 2                  ; 0
            sub     eax, ebx                ; 28
            mov     dword [temp_bss], eax   ; 28

            mov     ebx, eax                ; 28
            add     bl, byte [pool_pad]     ; 28
            add     bl, byte [pool_pad]     ; 28
        .origin_size_end:

        imul    eax, eax
        imul    eax, ecx                            ; Hanyadik bemenet
        imul    eax, 4

        mov     esi, dword [rajz]
        mov     esi, dword [rajz]
        add     esi, eax                            ; Eltolas
        mov     edi, dword [pool_padded]

        xor     ecx, ecx
        .yloop_pad:
            cmp     ecx, ebx           ; 28
            jge     .yloop_pad_end

            xor     edx, edx
            .xloop_pad:
                cmp     edx, ebx       ; 28
                jge     .xloop_pad_end

                ; if(pool_pad != 0 && ((y < pad || y >= size-pad) || (x < pad || x >= size-pad))) stosd 0; else stosd;
                cmp     byte [pool_pad], 0
                jne     .pady

                push    eax
                lodsd
                stosd
                pop     eax

                .pad_back:
                inc     edx
                jmp     .xloop_pad
            .xloop_pad_end:
            inc     ecx
            jmp     .yloop_pad
        .yloop_pad_end:

        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     eax
        ret

        .pady:
            cmp     ecx, dword [temp_bss] ; Ha meg nem ertunk a vegere
            jle     .pady2
            
            .pady_back:         ; 0-t tarolunk
            push    eax
            xor     eax, eax
            stosd
            pop     eax
            jmp     .pad_back

            .pady2:
                cmp     cl, byte [pool_pad]
                jl      .pady_back              ; Ha paddingen vagyunk
                jmp     .padx                   ; Kulonben kepben vagyunk

        .padx:
            cmp     ecx, dword [temp_bss] ; Ha meg nem ertunk a vegere
            jle     .padx2
            
            .padx_back:         ; 0-t tarolunk
            push    eax
            xor     eax, eax
            stosd
            pop     eax
            jmp     .pad_back

            .padx2:
                cmp     dl, byte [pool_pad]
                jl      .padx_back              ; Ha paddingen vagyunk
                push    eax                     ; Kulonben taroljuk a kep ertekeit
                lodsd
                stosd
                pop     eax
                jmp     .pad_back

Fc:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

    ;mov     eax, str_fc
    ;call    io_writestr
    ;call    io_writeln

    ; Lekeri a fuggveny fontos parametereit
    .parameterek:
        mov     eax, dword [parameter_cim]

        xor     ecx, ecx
        mov     cl, byte [sorszam]                              ; Fuggveny sorszama
        mov     ebx, [eax + 4*ecx]
        mov     eax, ebx

        xor     ebx, ebx
        mov     ebx, [eax]
        mov     dword [fc_in], ebx

        add     eax, 4
        xor     ebx, ebx
        mov     ebx, [eax]
        mov     dword [fc_out], ebx
    .parameterek_end:

    .allocate:
        mov     eax, dword [fc_out]
        imul    eax, 4
        call    mem_alloc
        mov     dword [fc_data], eax
    .allocate_end:

    mov     edi, dword [fc_data]            ; ide
    xor     ecx, ecx
    .loop:
        cmp     ecx, dword [fc_out]
        jge     .loop_end
        push    ecx
        mov     eax, ecx

        mov     esi, dword [rajz]           ; innen1
        xor     ecx, ecx
        xorps   xmm0, xmm0
        xorps   xmm1, xmm1
        xorps   xmm7, xmm7
        .loop2:
            cmp     ecx, dword [fc_in]
            jge     .loop2_end

            xor     eax, eax
            xorps   xmm0, xmm0
            xorps   xmm1, xmm1

            lodsd
            movd    xmm0, eax                    ; ertek

            push    esi
            mov     esi, dword [bin_current]
            lodsd
            movd    xmm1, eax                    ; suly
            mov     dword [bin_current], esi
            pop     esi

            mulss   xmm0, xmm1
            addss   xmm7, xmm0

            inc     ecx
            jmp     .loop2
        .loop2_end:

        movd    eax, xmm7
        stosd

        pop     ecx
        inc     ecx
        jmp     .loop
    .loop_end:

    mov     esi, dword [bin_current]
    mov     edi, dword [fc_data]
    xor     ecx, ecx
    .bias:
        cmp     ecx, dword [fc_out]
        jge     .bias_end
        
        xor     eax, eax
        xorps   xmm0, xmm0
        xorps   xmm1, xmm1

        lodsd                   ; bin_current + 4
        movd    xmm0, eax       ; bias
        xchg    edi, esi
        lodsd                   ; fc_out + 4
        movd    xmm1, eax       ; adat
        xchg    edi, esi
        sub     edi, 4

        addss   xmm0, xmm1
        movd    eax, xmm0
        stosd

        inc     ecx
        jmp     .bias
    .bias_end:

    mov     dword [bin_current], esi

    mov     eax, dword [fc_out]
    mov     dword[conv_out], eax

    mov     eax, dword [fc_data]
    mov     dword [rajz], eax

    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

Softmax:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi

    ;mov     eax, str_softmax
    ;call    io_writestr
    ;call    io_writeln

    mov     esi, dword [rajz]

    xor     ecx, ecx
    xorps   xmm6, xmm6
    .loop1:
        cmp     ecx, 10
        jge     .loop1_end

        xor     eax, eax
        xorps   xmm0, xmm0
        lodsd
        movd    xmm0, eax
        call    exp_ss              ; Exponencial

        addss   xmm6, xmm0          ; Osszeg

        inc     ecx
        jmp     .loop1
    .loop1_end:

    mov     esi, dword [rajz]

    xor     ecx, ecx
    .loop2:
        cmp     ecx, 10
        jge     .loop2_end

        xor     eax, eax
        xorps   xmm0, xmm0

        mov     eax, ecx
        call    io_writeint

        mov     eax, str_dash
        call    io_writestr

        lodsd
        movd    xmm0, eax
        call    exp_ss              ; Exp
        divss   xmm0, xmm6          ; Osztas
        call    io_writeflt

        call    io_writeln

        inc     ecx
        jmp     .loop2
    .loop2_end:
    call    io_writeln

    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret


;CNN

;DEBUG
VISUALIZE:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    edi
    push    esi

    mov     eax, 28
    mov     ebx, 28
    mov     ecx, 1
    mov     edx, 0

    call    gfx_init
    call    gfx_map

    push    eax
    ;mov     eax, dword [rajz]
    mov     esi, dword [rajz]
    mov     edi, eax
    mov     ecx, 28
    imul    ecx, ecx
    .copy:
        push    eax
        xorps   xmm0, xmm0
        xorps   xmm1, xmm1
        lodsd
        movd    xmm0, eax
        maxss   xmm1, xmm0
        movd    eax, xmm1
        stosd
        pop     eax
    loop    .copy

    call    gfx_unmap

    call    gfx_draw

    .esc:
        call    gfx_getevent
        cmp     eax, 27
        je      .esc_end

        jmp     .esc
    .esc_end:
    pop     eax

    call    gfx_destroy

    pop     esi
    pop     edi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

VISUALIZE2:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    edi
    push    esi

    mov     eax, 28
    mov     ebx, 28
    mov     ecx, 1
    mov     edx, 0

    call    gfx_init

    mov     esi, dword [rajz]
    xor     ecx, ecx
    .loop:
        cmp     ecx, dword [conv_out]
        jge     .loop_end
        push    ecx
        call    gfx_map
    
        ;xor     ebx, ebx
        ;mov     esi, dword [rajz]
            ;mov     bl, byte [size]
            ;imul    ebx, ebx
            ;imul    ebx, 4
            ;imul    ebx, ecx
            ;add     esi, ebx
        mov     edi, eax
        xor     ecx, ecx
        mov     cl, byte [size]
        imul    ecx, ecx
        .copy:
            push    eax
            xorps   xmm0, xmm0
            xorps   xmm1, xmm1
            lodsd
            movd    xmm0, eax
            maxss   xmm1, xmm0
            movd    eax, xmm1
            stosd
            pop     eax
        loop    .copy

        call    gfx_unmap

        call    gfx_draw

        .esc:
            call    gfx_getevent
            cmp     eax, 27
            je      .loop_end
            cmp     eax, -1
            je      .esc_end

            jmp     .esc
        .esc_end:
        pop     ecx
        inc     ecx
        jmp    .loop
    .loop_end:

    call    gfx_destroy

    pop     esi
    pop     edi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

VISUALIZE3:
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    edi
    push    esi

    mov     eax, 28
    mov     ebx, 28
    mov     ecx, 1
    mov     edx, 0

    call    gfx_init

    xor     ecx, ecx
    xor     edx, edx
    mov     edx, dword [conv_out]
    imul    edx, 2
    .loop:
        cmp     ecx, edx
        jge     .loop_end
        push    ecx
        call    gfx_map
    
        xor     ebx, ebx
        mov     esi, dword [rajz]
            mov     bl, byte [size]
            imul    ebx, ebx
            imul    ebx, 4
            imul    ebx, ecx
            add     esi, ebx
        mov     edi, eax

        xor     ecx, ecx
        mov     ecx, 14
        .big:
            push    ecx
            xor     ecx, ecx
            mov     ecx, 14
            .copy:
                push    eax
                xorps   xmm0, xmm0
                xorps   xmm1, xmm1
                lodsd
                movd    xmm0, eax
                maxss   xmm1, xmm0
                movd    eax, xmm1
                stosd
                pop     eax
            loop    .copy

            xor     ecx, ecx
            mov     ecx, 14
            .fill:
            push    eax
            lodsd
            xor     eax, eax
            stosd
            pop     eax
            loop    .fill
            pop     ecx
        loop    .big
        mov     ecx, 14
        .big2:
            push    ecx
            mov     ecx, 28
            xor     eax, eax
            .big3:
                stosd
            loop    .big3
            pop     ecx
        loop    .big2

        call    gfx_unmap

        call    gfx_draw

        .esc:
            call    gfx_getevent
            cmp     eax, 27
            je      .loop_end
            cmp     eax, -1
            je      .esc_end

            jmp     .esc
        .esc_end:
        pop     ecx
        inc     ecx
        jmp    .loop
    .loop_end:

    call    gfx_destroy

    pop     esi
    pop     edi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret

;DEBUG

section .data
    ;CNN
    const_mean      dd 0.1307
    const_std       dd 0.3081

    bin_size        dd 0
    bin_adat        dd 0
    bin_current     dd 0

    sorszam         dd 0
    parameter_cim   dd 0

    rajz_full       dd 0
    rajz            dd 0

    conv_temp       dd 0
    conv_padded     dd 0
    conv_filter     dd 0
    pool_padded     dd 0
    temp_data       dd 0
    fc_data         dd 0

    fc_in           dd 0
    fc_out          dd 0

    conv_out        dd 0
    conv_in         db 0
    conv_kx         db 0
    conv_ky         db 0
    conv_padx       db 0
    conv_pady       db 0

    pool_k          db 0
    pool_str        db 0
    pool_pad        db 0

    size            db 28

    net_txt         db "cnn_with_pad.txt", 0
    ;net_txt         db "cnn_no_pad.txt", 0
    ;net_txt         db "lin_model.txt", 0
    ;net_txt         db "conv1.txt", 0
    net_bin         db "cnn_with_pad.bin", 0
    ;net_bin         db "cnn_no_pad.bin", 0
    ;net_bin         db "lin_model.bin", 0
    ;net_bin         db "conv1.bin", 0

    rajz_bin        db "rajz.bin", 0

    str_pre         db "preprocess", 10, 0
    str_conv        db "conv", 10, 0
    str_relu        db "relu", 10, 0
    str_pool        db "pool", 10, 0
    str_fc          db "fc", 10, 0
    str_softmax     db "softmax", 10, 0

    str_dash        db " ==== ", 0
    ;CNN

    ;GRAFIKA
    rajz_adat       dd  0
    file_handle     dd  0

    str_help1       db  "Zold  gomb == Rajz kiirasa binaris fajlba", 0
    str_help2       db  "Piros gomb == Rajzfelulet torlese", 0
    str_hiba        db  "Nem sikerult letrehozni az ablakot!", 0
    str_title       db  "Projekt", 0
    str_X           db  "X = ", 0
    str_Y           db  "   Y = ", 0
    str_space       db  "       ", 0

    file_rajz       db  "rajz.bin", 0

    cr              db  13, 0

    MouseX          dd  0
    MouseY          dd  0
    ;GRAFIKA

section .bss
    ;GRAFIKA
    map_cim             resd    1
    ;GRAFIKA

    ;CNN
    temp_bss            resb 16
    fuggvenyek          resb 64
    adat                resb 1024
    ;CNN