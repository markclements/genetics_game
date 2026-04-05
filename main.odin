package game

import "core:fmt"
import "core:os"
import rl "vendor:raylib"
import "core:strings"


Locus :: struct {
    name: string, 
    allele: string,
    position: f32
}

Segment :: struct {
    chromatid_parent_id: string,
    rect: rl.Rectangle,
    loci: [dynamic]Locus,
}

Chromatid :: struct {
    chromatid_id: string,
    rect: rl.Rectangle,
    segments: [dynamic]Segment,
    // dragging: bool,
    // drag_offset: rl.Vector2
}

ChromatidPair :: struct {
    pair_id: string,
    x_pos: f32,
    y_pos: f32,
    left_chrom: Chromatid,
    right_chrom: Chromatid
}


init_chromatid_pair :: proc(pair_id: string, left_length: f32, right_length: f32, x_pos: f32, y_pos: f32) -> ChromatidPair {
    right_segment_array: [dynamic]Segment
    left_segment_array: [dynamic]Segment

    right_locus_array: [dynamic]Locus
    left_locus_array: [dynamic]Locus


    right_seg: = Segment {
        chromatid_parent_id = "right",
        rect = rl.Rectangle {
            x_pos + 30, // offset for visual separation
            y_pos,
            25,
            right_length
        },
        loci = right_locus_array,
    }

    left_seg: = Segment {
        chromatid_parent_id = "left", 
        rect = rl.Rectangle {
            x_pos,
            y_pos,
            25,
            left_length
        }, 
        loci = left_locus_array,
    } 

    append(&right_segment_array, right_seg)
    append(&left_segment_array, left_seg)


    left_chrom:= Chromatid {
        chromatid_id = "left",
        rect = rl.Rectangle {
            x_pos,
            y_pos,
            25,
            left_length
        },
        segments = left_segment_array    
    }

    right_chrom:= Chromatid {
        chromatid_id = "right",
        rect = rl.Rectangle {
            x_pos + 30, // offset for visual separation
            y_pos,
            25,
            right_length
        },
        segments = right_segment_array,
    }

    return( 
        ChromatidPair {
            pair_id,
            x_pos,
            y_pos,
            left_chrom,
            right_chrom
        }
    )
}


add_locus :: proc(chrom_pair: ^ChromatidPair, locus_name: string, left_allele: string, right_allele: string, position: f32) {
    left_locus: = Locus {
      name = locus_name,
        allele = left_allele,
        position = position
    }
    right_locus: = Locus {
        name = locus_name,
        allele = right_allele,
        position = position
    }
    append(&chrom_pair.left_chrom.segments[0].loci, left_locus)
    append(&chrom_pair.right_chrom.segments[0].loci, right_locus)
}

draw_chrom_pair :: proc(chroms: ChromatidPair) {
     
    rl.DrawRectangleLinesEx(chroms.left_chrom.rect, 0.75, rl.RED) // left
    rl.DrawRectangleLinesEx(chroms.right_chrom.rect, 0.75, rl.BLUE) // right

    for seg in chroms.left_chrom.segments {
        rl.DrawRectangle(i32(seg.rect.x + 5 ), i32(seg.rect.y), i32(seg.rect.width-10), i32(seg.rect.height), rl.RED)
    }

    for seg in chroms.right_chrom.segments {
        rl.DrawRectangle(i32(seg.rect.x +5 ), i32(seg.rect.y), i32(seg.rect.width-10), i32(seg.rect.height), rl.BLUE)
    }
}

split_chrom :: proc(chrom: ^ChromatidPair, click_position: [2]f32) {

    relative_click_pos := click_position.y - chrom.left_chrom.rect.y 

           // chrom_start := 
            chrom_height := chrom.left_chrom.segments[0].rect.height

            chrom.left_chrom.segments[0].rect.height = relative_click_pos

            new_segment_rect := rl.Rectangle {
                x = chrom.left_chrom.rect.x,
                y = click_position.y,
                height = chrom_height - relative_click_pos,
                width = 20
            }
        
            new_segment_loci : [dynamic]Locus
        
            new_segment := Segment {
                chromatid_parent_id = chrom.pair_id,
                loci = new_segment_loci,
                rect = new_segment_rect
            }
            
            append(&chrom.left_chrom.segments, new_segment)

            fmt.println(chrom.left_chrom)

}


main :: proc() {
    rl.InitWindow(1280, 720, "My Odin + Raylib game")

    sh := rl.GetScreenHeight()
    sw := rl.GetScreenWidth()

    chrom_1: = init_chromatid_pair("1", 100, 100, f32(sw/2), f32(sh/2))

    add_locus(&chrom_1, "color", "a", "b", 50)
    add_locus(&chrom_1, "wings", "B", "b", 90)

    //fmt.println(chrom_1.left_chrom.segments[:])
    //fmt.printfln(str)

	


    for !rl.WindowShouldClose() { // main loop starts here

        mouse_pos := rl.GetMousePosition()

        if  rl.IsMouseButtonPressed(.RIGHT) && rl.CheckCollisionPointRec(mouse_pos, chrom_1.left_chrom.rect) || 
            rl.IsMouseButtonPressed(.RIGHT) && rl.CheckCollisionPointRec(mouse_pos, chrom_1.right_chrom.rect) {
            split_chrom(&chrom_1, mouse_pos) 
        }

        /*

        if rl.IsMouseButtonPressed(.LEFT) && rl.CheckCollisionPointRec(mouse_pos, chrom.rec) {
                chrom.dragging = true  
                chrom.drag_offset = mouse_pos - { chrom.rec.x, chrom.rec.y }      
        }
        
        if chrom.dragging {
            new_pos := mouse_pos - chrom.drag_offset 
            chrom.rec.x = new_pos.x
            chrom.rec.y = new_pos.y

            // fmt.printfln("mouse: %v, offset: %v, new: %v", mouse_pos, chrom.drag_offset, new_pos)

                if rl.IsMouseButtonReleased(.LEFT) {
                chrom.dragging = false
            }
        }
        
        if rl.IsMouseButtonPressed(.RIGHT) && rl.CheckCollisionPointRec(mouse_pos, chrom.rec) {
            fmt.printfln("right click")

        
        }
		
        */
        rl.BeginDrawing()
		rl.ClearBackground({160, 200, 255, 255})

            
            draw_chrom_pair(chrom_1)
            
            text := fmt.tprintf("Mouse Pos: [%d, %d]", i32(mouse_pos.x), i32(mouse_pos.y))
            rl.DrawText(strings.clone_to_cstring(text, context.temp_allocator), 10, 10, 20, rl.BLACK)
        
        rl.EndDrawing()

}
	rl.CloseWindow() // main loop ends here

}