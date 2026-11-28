"""Build diagonal road ends from the game's extracted brushes/world_detail.brush."""

import argparse
from pathlib import Path

from build_wx_mirrored_vfx import read_brush_records
from compile_wuxia_brushes import write_brush_binary


def build(stock_sheet):
    texture, atlas_size, records = read_brush_records(stock_sheet)
    by_id = {record["id"]: record for record in records}
    ends = []
    for road_id, directions in (("road_NW_SE", ("NW", "SE")), ("road_SW_NE", ("SW", "NE"))):
        road = by_id[road_id]
        for direction in directions:
            u0, u1, v0, v1, left, right, bottom, top = road["uv_quad"]
            # Clip both the texture and the world quad at the centre of the tile.
            centre_u = u0 + (u1 - u0) * (-left / (right - left))
            if direction.endswith("W"):
                u1, right = centre_u, 0
            else:
                u0, left = centre_u, 0
            ends.append(dict(road, id="wx_road_end_" + direction,
                             uv_quad=(u0, u1, v0, v1, left, right, bottom, top)))

    output = Path(__file__).resolve().parents[1] / "mod_wuxia/brushes/wx_road_ends.brush"
    write_brush_binary(str(output), texture, atlas_size, ends)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("stock_sheet", type=Path)
    build(parser.parse_args().stock_sheet)
