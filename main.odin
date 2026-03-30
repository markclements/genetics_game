package game

import "core:fmt"
import "core:os"
import rl "vendor:raylib"


Locus :: struct {
    name: string, 
    allele: string,
    position: f32
}

Segment :: struct {
    chromatid_parent_id: string,
    loci: [dynamic]Locus,
   // dragging: bool,
   // drag_offset: rl.Vector2
}

Chromatid :: struct {
    chromatid_id: string,
    segments: [dynamic]Segment,
    length: f32
}

ChromatidPair :: struct {
    pair_id: string,
    left_chrom: Chromatid,
    right_chrom: Chromatid
}

make_locus :: proc(locus_name: string, alleles: []string, position: f32) -> []Locus {
    locus_array : [dynamic]Locus
    for allele in alleles {
        locus := Locus {
            locus_name,
            allele,
            position
        }
        append(&locus_array, locus)
    }
    return(locus_array)[:]
}



init_chromatid_pair :: proc(pair_id: string, left_length: f32, right_length: f32) -> ChromatidPair {
    right_segment_array: [dynamic]Segment
    left_segment_array: [dynamic]Segment

    right_locus_array: [dynamic]Locus
    left_locus_array: [dynamic]Locus


    right_seg: = Segment {
        "right",
        right_locus_array
    }

    left_seg: = Segment {
        "left",
        left_locus_array
    } 

    append(&right_segment_array, right_seg)
    append(&left_segment_array, left_seg)


    left_chrom:= Chromatid {
        "left",
        left_segment_array,
        left_length
    }

    right_chrom:= Chromatid {
        "right", 
        right_segment_array,
        right_length
    }
    
    return( 
        ChromatidPair {
            pair_id,
            left_chrom,
            right_chrom
        }
    )
}


add_locus :: proc(chrom_pair: ChromatidPair, locus_name: string, left_allele: string, right_allele: string, position: f32) {
    left_locus: = Locus {
        locus_name,
        left_allele,
        position
    }
    right_locus: = Locus {
        locus_name,
        right_allele,
        position
    }
    append(&chrom_pair.left_chrom.segments[0].loci, left_locus)
    append(&chrom_pair.right_chrom.segments[0].loci, right_locus)
}



main :: proc() {


    chrom_1: = init_chromatid_pair("1", 100, 100)

    add_locus(chrom_1, "color", "a", "b", 50)
    add_locus(chrom_1, "wings", "B", "b", 90)

    fmt.println(chrom_1.left_chrom.segments[:])
    //fmt.printfln(str)

	rl.InitWindow(1280, 720, "My Odin + Raylib game")
    rec := rl.Rectangle { 300, 300, 50, 200 }


    for !rl.WindowShouldClose() {

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

        //    rl.DrawRectangleRec(chrom.rec,  chrom.dragging ? rl.MAROON : rl.RED)
        
        rl.EndDrawing()

}
	rl.CloseWindow()

}