package main

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

Selection_Square :: struct {
    rect : rl.Rectangle,
    thiccness : f32,
    color : rl.Color,
}

Pixel :: struct {
    pos : [2]i32,
    dir : [2]i16,
    color : [3]u8,
    active_channel : u8
}

main :: proc() {
    
    WIDTH   :: 300
    HEIGHT  :: 300
    TITLE : cstring : "Target Pixel"
    
    rl.SetTraceLogLevel(rl.TraceLogLevel.ERROR)

    flags : rl.ConfigFlags
    flags = {.WINDOW_TOPMOST} // .VSYNC_HINT for auto monitor dependent refresh
    rl.SetConfigFlags(flags)

    rl.InitWindow(WIDTH, HEIGHT, TITLE)

    monitor := rl.GetCurrentMonitor()
    monitor_count := rl.GetMonitorCount()
    window_pos := get_window_pos(&monitor)

    pixel : Pixel = {
        {50, 50},
        {0,0},
        rl.GREEN.rgb,
        0
    }

    square : Selection_Square = {
        {100, HEIGHT - 30, 40, 30},
        2, rl.DARKGRAY
    }
    move_square(pixel.active_channel, &square)
    
    clear_color := rl.BLACK  
    textensity : u8 = 200 
    randomize_pixel := false

    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {

        { using pixel
            active_channel = u8(i32(active_channel) + get_axis_pressed(.A, .D) + 3) % 3
            move_square(active_channel, &square)
 
            color[active_channel] = u8(clamp(i32(color[active_channel]) + get_axis_held(.S, .W), 0, 255))

            if rl.IsMouseButtonPressed(.LEFT) {
                pos.x = rl.GetMouseX()
                pos.y = rl.GetMouseY()
                window_pos = get_window_pos(&monitor)
            } else {
                dir.x = i16(get_axis_pressed(.LEFT, .RIGHT))
                dir.y = i16(get_axis_pressed(.UP, .DOWN))
                if dir.x != 0 || dir.y != 0 {
                    pos.x += i32(dir.x)
                    pos.y += i32(dir.y)
                    window_pos = get_window_pos(&monitor)
                    dir = {0,0}
                }
            }
        }

        if rl.IsKeyPressed(.X){
            randomize_pixel = !randomize_pixel
        }
        if rl.IsKeyPressed(.Z){
            if clear_color.r == 0 {
                clear_color = rl.WHITE
            } else {
                clear_color = rl.BLACK
            }
        }

        rl.BeginDrawing()
            rl.ClearBackground(clear_color)

            { using pixel 
                rl.DrawText(fmt.ctprintf("position: %d, %d", window_pos.x + pos.x, window_pos.y + pos.y), 10, 5, 20, rl.DARKGRAY)
                if monitor_count > 1 {
                    rl.DrawText(fmt.ctprintf("monitor: %d", monitor), 10, 30, 20, rl.DARKGRAY)
                }
                
                if randomize_pixel {
                    rl.DrawText("randomizing...", WIDTH / 2 - 100, HEIGHT - 25, 20, rl.DARKGRAY)
                    rl.DrawPixel(pos.x, pos.y, {rand_u8(), rand_u8(), rand_u8(), 255})
                } else {
                    rl.DrawText(fmt.ctprintf("%d", color.r), WIDTH / 2 - i32(square.rect.width) - 18,   HEIGHT -25, 20, {textensity, 0, 0, 255})
                    rl.DrawText(fmt.ctprintf("%d", color.g), WIDTH / 2 - 18,                            HEIGHT -25, 20, {0, textensity, 0, 255})
                    rl.DrawText(fmt.ctprintf("%d", color.b), WIDTH / 2 + i32(square.rect.width) - 18,   HEIGHT -25, 20, {0, 0, textensity, 255})
                    rl.DrawRectangleLinesEx(square.rect, square.thiccness, square.color)
                    rl.DrawPixel(pos.x, pos.y, {color.r, color.g, color.b, 255})
                }
            }
            
        rl.EndDrawing()

        free_all(context.temp_allocator)
    }
    rl.CloseWindow()
}

move_square :: proc(position : u8, using square : ^Selection_Square) {
    rect.x = f32(position) * rect.width + (150 - rect.width * 3 / 2)
}

rand_u8 :: #force_inline proc() -> u8 {
    return u8(rand.int31() % 256)
}

get_window_pos :: proc(monitor : ^i32) -> [2]i32 {
    monitor^ = rl.GetCurrentMonitor()
    pos := rl.GetWindowPosition() - rl.GetMonitorPosition(monitor^)
    return {i32(pos.x), i32(pos.y)}
}

get_axis_held :: proc(neg, pos : rl.KeyboardKey) -> i32 {
    out : i32
    if rl.IsKeyDown(neg) {out -= 1}
    if rl.IsKeyDown(pos) {out += 1}
    return out
}

get_axis_pressed :: proc(neg, pos : rl.KeyboardKey) -> i32 {
    out : i32
    if rl.IsKeyPressed(neg) {out -= 1}
    if rl.IsKeyPressed(pos) {out += 1}
    return out
}