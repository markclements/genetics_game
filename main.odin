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
    color: rl.Color,
    hovered: bool,
    dragging: bool,
    drag_offset: rl.Vector2
}

HomologousPair :: struct {
    pair_id: string, //"1", "XY"
    x_pos : f32, // starting position, might be used to drive positions and animations? 
    y_pos: f32,
    chromatids: [4]Chromatid, // ordered 0,1,2,3; 1 and 2 are nonsister and capable of crossover, 0 and 3 are non sister and do not crossover
                             // 4 because of duplication so we don't have to write proc to duplicate chromatid. Just hide or show based upon state. 
}

Genome :: [dynamic]HomologousPair

init_chromatid_pair :: proc(pair_id: string, left_length: f32, right_length: f32, x_pos: f32, y_pos: f32) -> HomologousPair {
    r_right_segment_array: [dynamic]Segment
    l_left_segment_array: [dynamic]Segment
    right_segment_array: [dynamic]Segment
    left_segment_array: [dynamic]Segment

    r_right_locus_array: [dynamic]Locus
    l_left_locus_array: [dynamic]Locus
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

    r_right_seg:= right_seg
    r_right_seg.color = rl.BLACK
    r_right_seg.loci = r_right_locus_array

    l_left_seg:= left_seg
    l_left_seg.color = rl.BROWN
    l_left_seg.loci = l_left_locus_array

    append(&right_segment_array, right_seg)
    append(&left_segment_array, left_seg)
    append(&l_left_segment_array, l_left_seg)
    append(&r_right_segment_array, r_right_seg)

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

    l_left_chrom:= Chromatid {
        chromatid_id = "left",
        rect = rl.Rectangle {
            x_pos - 30,
            y_pos,
            25,
            left_length,
        }, 
        segments = l_left_segment_array, 
        color = rl.GRAY        
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

    r_right_chrom:= Chromatid {
        chromatid_id = "right",
        rect = rl.Rectangle {
            x_pos + 30 + 30, // offset for visual separation
            y_pos,
            25,
            right_length
        },
        segments = r_right_segment_array,
        color = rl.BLACK
    }

    return HomologousPair { 
        pair_id = pair_id,
        x_pos = x_pos,
        y_pos = y_pos,
        chromatids = {l_left_chrom, left_chrom, right_chrom, r_right_chrom}
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
        append(&chrom_pair.chromatids[0].segments[0].loci, left_locus)
        append(&chrom_pair.chromatids[1].segments[0].loci, left_locus)
        append(&chrom_pair.chromatids[2].segments[0].loci, right_locus)
        append(&chrom_pair.chromatids[3].segments[0].loci, right_locus)
    
}


draw_chrom_pair :: proc(chroms: HomologousPair) {
    for chrom in chroms.chromatids {
        if chrom.hovered {
            rl.DrawRectangleLinesEx(chrom.rect, 0.75, rl.YELLOW)
        }
        else {
            rl.DrawRectangleLinesEx(chrom.rect, 0.75, chrom.color)
         }
            for seg in chrom.segments {
                rl.DrawRectangle(i32(seg.rect.x + 5 ), i32(seg.rect.y), i32(seg.rect.width-10), i32(seg.rect.height), seg.color)
        }

    }
}

highlight_chroms :: proc(chroms: ^HomologousPair, mouse_pos: rl.Vector2) {
     for chrom in chroms.chromatids {
        for &chromatids in chroms.chromatids {
            if rl.CheckCollisionPointRec(mouse_pos, chromatids.rect) {
                chromatids.hovered = true
                }
            else {
                chromatids.hovered = false
            }    
        }
     }
}

drag_chroms :: proc(chroms: ^HomologousPair, mouse_pos:rl.Vector2) {
    #reverse for chrom in chroms.chromatids {
        for &chromatids in chroms.chromatids {
            if chromatids.hovered && rl.IsMouseButtonPressed(.LEFT) {
                chromatids.dragging = true  
                chromatids.drag_offset = mouse_pos - { chromatids.rect.x, chromatids.rect.y }
            }
            if chromatids.dragging {
            new_pos := mouse_pos - chromatids.drag_offset 
                chromatids.rect.x = new_pos.x
                chromatids.rect.y = new_pos.y
            fmt.printfln("mouse: %v, offset: %v, new: %v", mouse_pos, chrom.drag_offset, new_pos)

                if rl.IsMouseButtonReleased(.LEFT) {
                chromatids.dragging = false
                }
            }
        }
    }
}

update_segment_positions :: proc(chroms: ^HomologousPair) {
    for chrom in chroms.chromatids {
        for chromatids in chroms.chromatids {
            parent_pos:= chromatids.rect 
            for &segments in chromatids.segments {
                segments.rect.x = parent_pos.x
                segments.rect.y = parent_pos.y
            }
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

    chrom_2: = init_chromatid_pair("2", 100, 100, f32(sw/2), f32(sh/2) + 125)

    add_locus(&chrom_2, "size", "c", "C", 30)
    add_locus(&chrom_2, "type", "D", "d", 70)

    genome:[dynamic]HomologousPair

    append(&genome, chrom_1, chrom_2)

    //fmt.println(chrom_1.left_chrom.segments[:])
    //fmt.printfln(str)

	//fmt.printf("Address 1: %p\n Address 2: %p\n", &chrom_1[0], &chrom_1[1])



    for !rl.WindowShouldClose() { // main loop starts here

        mouse_pos := rl.GetMousePosition()

        for &chromosomes in genome {
            highlight_chroms(&chromosomes, mouse_pos)
            drag_chroms(&chromosomes, mouse_pos)
            update_segment_positions(&chromosomes)
        }
           
    
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