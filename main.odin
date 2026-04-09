package game

import "core:fmt"
import "core:os"
import rl "vendor:raylib"
import "core:strings"


Locus :: struct {
    name: string, 
    allele: string,
    position: f32,
}

Segment :: struct {
    chromatid_parent_id: string,
    rect: rl.Rectangle,
    loci: [dynamic]Locus,
    color: rl.Color
}

Chromatid :: struct {
    pair_id: string,
    chromatid_id: string,
    rect: rl.Rectangle,
    segments: [dynamic]Segment,
    color: rl.Color
    // dragging: bool,
    // drag_offset: rl.Vector2
}

HomologousPair :: struct {
    pair_id: string, //"1", "XY"
    x_pos : f32, // starting position, might be used to drive positions and animations? 
    y_pos: f32,
    chromatids: [4]Chromatid, // ordered 0,1,2,3; 1 and 2 are nonsister and capable of crossover, 0 and 3 are non sister and do not crossover
                             // 4 because of duplication so we don't have to write proc to duplicate chromatid. Just hide or show based upon state. 
}

ChromPair :: [4]Chromatid
Genome :: [dynamic]ChromPair

init_chromatid_pair :: proc(pair_id: string, left_length: f32, right_length: f32, x_pos: f32, y_pos: f32) -> HomologousPair {
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
        color = rl.BLUE
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
        color = rl.RED
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
        segments = left_segment_array,
        color = rl.RED    
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
        color = rl.BLUE
    }

    return HomologousPair { 
        pair_id = pair_id,
        x_pos = x_pos,
        y_pos = y_pos,
        chromatids = {left_chrom, left_chrom, right_chrom, right_chrom}
    }
}

add_locus :: proc(chrom_pair: ^HomologousPair, locus_name: string, left_allele: string, right_allele: string, position: f32) {
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
    append(&HomologousPair.chromatids[0].segments[0].loci, left_locus)
    append(&HomologousPair.chromatids[1].segments[0].loci, left_locus)
    append(&HomologousPair.chromatids[2].segments[0].loci, left_locus)
    append(&HomologousPair.chromatids[3].segments[0].loci, left_locus)
}

draw_chrom_pair :: proc(chroms: ChromPair) {
    for chrom in chroms {
        rl.DrawRectangleLinesEx(chrom.rect, 0.75, chrom.color) // left
            for seg in chrom.segments {
                rl.DrawRectangle(i32(seg.rect.x + 5 ), i32(seg.rect.y), i32(seg.rect.width-10), i32(seg.rect.height), seg.color)
        }
    }
}
/*
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

}*/


main :: proc() {
    rl.InitWindow(1280, 720, "My Odin + Raylib game")

    sh := rl.GetScreenHeight()
    sw := rl.GetScreenWidth()

    chrom_1: = init_chromatid_pair("1", 100, 100, f32(sw/2), f32(sh/2))

    add_locus(&chrom_1, "color", "a", "b", 50)
    add_locus(&chrom_1, "wings", "B", "b", 90)

    // chrom_2: = init_chromatid_pair("2", 100, 100, f32(sw/2), f32(sh/2) + 125)

    // add_locus(&chrom_2, "size", "c", "C", 30)
    // add_locus(&chrom_2, "type", "D", "d", 70)

    genome:[dynamic]ChromPair

   // append(&genome, chrom_1, chrom_2)

    //fmt.println(chrom_1.left_chrom.segments[:])
    //fmt.printfln(str)

	//fmt.printf("Address 1: %p\n Address 2: %p\n", &chrom_1[0], &chrom_1[1])



    for !rl.WindowShouldClose() { // main loop starts here

        mouse_pos := rl.GetMousePosition()

        

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

            for chrom in genome {
                draw_chrom_pair(chrom)
            }
            text := fmt.tprintf("Mouse Pos: [%d, %d]", i32(mouse_pos.x), i32(mouse_pos.y))
            rl.DrawText(strings.clone_to_cstring(text, context.temp_allocator), 10, 10, 20, rl.BLACK)
        
        rl.EndDrawing()

}
	rl.CloseWindow() // main loop ends here

}