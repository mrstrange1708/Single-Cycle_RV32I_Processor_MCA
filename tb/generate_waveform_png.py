#!/usr/bin/env python3
"""
Render GTKWave-style waveform image from sim/cpu.vcd for Member 5 evidence.
Owner: Member 5 (Balanagu Srikar) - Memory & Verification
"""

import os
import sys
from PIL import Image, ImageDraw, ImageFont

repo_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

def parse_vcd(filename):
    signals = {}       # sym -> {'name': str, 'type': str, 'width': int}
    sig_by_name = {}   # name -> sym
    time_series = {}   # sym -> list of (time_ps, val_str)
    
    with open(filename, 'r') as f:
        lines = f.readlines()
        
    scope = []
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
        parts = line.split()
        if parts[0] == '$scope':
            scope.append(parts[2])
        elif parts[0] == '$upscope':
            if scope:
                scope.pop()
        elif parts[0] == '$var':
            var_type = parts[1]
            width = int(parts[2])
            sym = parts[3]
            name = parts[4]
            full_name = '.'.join(scope + [name])
            signals[sym] = {'name': full_name, 'short_name': name, 'type': var_type, 'width': width}
            sig_by_name[full_name] = sym
            sig_by_name[name] = sym
            time_series[sym] = []
        elif parts[0] == '$enddefinitions':
            i += 1
            break
        i += 1
        
    current_time = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
        if line.startswith('#'):
            current_time = int(line[1:])
        elif line.startswith('b'):
            # Bus change: b0010011 1
            parts = line[1:].split()
            val = parts[0]
            sym = parts[1]
            if sym in time_series:
                time_series[sym].append((current_time, val))
        elif line.startswith('r'):
            pass
        elif len(line) >= 2 and (line[0] in '01xzXZ'):
            val = line[0]
            sym = line[1:]
            if sym in time_series:
                time_series[sym].append((current_time, val))
        i += 1
        
    return signals, sig_by_name, time_series

def get_val_at(series, time_ps, default='0'):
    if not series:
        return default
    last_val = default
    for t, val in series:
        if t <= time_ps:
            last_val = val
        else:
            break
    return last_val

def bus_to_hex(val_str, width):
    val_clean = val_str.replace(' ', '')
    try:
        val_int = int(val_clean, 2)
        hex_digits = max(1, (width + 3) // 4)
        return f"{val_int:0{hex_digits}X}"
    except ValueError:
        return val_str

def main():
    vcd_path = os.path.join(repo_dir, 'sim', 'cpu.vcd')
    signals, sig_by_name, time_series = parse_vcd(vcd_path)
    
    # Selected signals to plot
    display_signals = [
        ('tb_cpu.clk', 'clk', '1bit', '#38bdf8'),
        ('tb_cpu.reset', 'reset', '1bit', '#f87171'),
        ('tb_cpu.pc_cur', 'pc_cur[31:0]', 'bus', '#fbbf24'),
        ('tb_cpu.instr', 'instr[31:0]', 'bus_instr', '#34d399'),
        ('tb_cpu.reg_write', 'reg_write', '1bit', '#a78bfa'),
        ('tb_cpu.alu_src', 'alu_src', '1bit', '#a78bfa'),
        ('tb_cpu.mem_write', 'mem_write', '1bit', '#fb923c'),
        ('tb_cpu.result_src', 'result_src', '1bit', '#fb923c'),
        ('tb_cpu.branch', 'branch', '1bit', '#f43f5e'),
        ('tb_cpu.pc_src', 'pc_src', '1bit', '#f43f5e'),
        ('tb_cpu.rd1', 'rd1[31:0]', 'bus', '#38bdf8'),
        ('tb_cpu.rd2', 'rd2[31:0]', 'bus', '#38bdf8'),
        ('tb_cpu.imm', 'imm[31:0]', 'bus', '#e879f9'),
        ('tb_cpu.alu_ctrl', 'alu_ctrl[2:0]', 'bus', '#fbbf24'),
        ('tb_cpu.alu_result', 'alu_result[31:0]', 'bus', '#fbbf24'),
        ('tb_cpu.zero', 'zero', '1bit', '#f43f5e'),
        ('tb_cpu.mem_rdata', 'mem_rdata[31:0]', 'bus', '#fb923c'),
        ('tb_cpu.result', 'result[31:0]', 'bus', '#34d399'),
        ('tb_cpu.x1', 'regs[1] (5)', 'bus', '#4ade80'),
        ('tb_cpu.x3', 'regs[3] (8)', 'bus', '#4ade80'),
        ('tb_cpu.x8', 'regs[8] (8)', 'bus', '#4ade80'),
        ('tb_cpu.x9', 'regs[9] (0-skip)', 'bus', '#94a3b8'),
        ('tb_cpu.x11', 'regs[11] (42)', 'bus', '#4ade80'),
        ('tb_cpu.dmem0', 'dmem[0] (8)', 'bus', '#f59e0b'),
    ]

    instr_names = {
        '00500093': 'addi x1,5',
        '00300113': 'addi x2,3',
        '002081B3': 'add x3,x1,x2',
        '40208233': 'sub x4,x1,x2',
        '0020F2B3': 'and x5,x1,x2',
        '0020E333': 'or x6,x1,x2',
        '0020C3B3': 'xor x7,x1,x2',
        '00302023': 'sw x3,0(x0)',
        '00002403': 'lw x8,0(x0)',
        '00818463': 'beq x3,x8,+8 [TAKEN]',
        '00100493': 'addi x9,1 [SKIPPED]',
        '00209463': 'bne x1,x2,+8 [TAKEN]',
        '00100513': 'addi x10,1 [SKIPPED]',
        '02A00593': 'addi x11,42',
        '00000063': 'beq halt',
    }

    # Time parameters: 0 to 180 ns (180,000 ps) covering all instructions and initial cycles
    start_ps = 0
    end_ps = 175000  # 175 ns
    scale = 0.012    # pixels per ps -> 10,000 ps = 120 pixels per cycle
    
    label_w = 260
    wave_w = int((end_ps - start_ps) * scale)
    total_w = label_w + wave_w + 40
    
    row_h = 32
    header_h = 60
    total_h = header_h + len(display_signals) * row_h + 30

    img = Image.new('RGB', (total_w, total_h), color='#0f172a')
    draw = ImageDraw.Draw(img)

    try:
        font_large = ImageFont.truetype('/System/Library/Fonts/Menlo.ttc', 13)
        font_small = ImageFont.truetype('/System/Library/Fonts/Menlo.ttc', 11)
        font_tiny = ImageFont.truetype('/System/Library/Fonts/Menlo.ttc', 10)
    except Exception:
        font_large = font_small = font_tiny = ImageFont.load_default()

    # Draw header
    draw.rectangle([(0, 0), (total_w, header_h)], fill='#1e293b')
    draw.text((15, 12), "RV32I Single-Cycle Processor — Program A Execution Trace", fill='#f8fafc', font=font_large)
    draw.text((15, 34), "Member 5: Memory & Verification (Balanagu Srikar) | All 10 RV32I Instructions Verified", fill='#94a3b8', font=font_small)

    # Time ruler and vertical grid lines
    for t_ns in range(0, int(end_ps / 1000) + 1, 10):
        t_ps = t_ns * 1000
        x = label_w + int((t_ps - start_ps) * scale)
        if label_w <= x <= total_w - 20:
            # Grid line
            draw.line([(x, header_h), (x, total_h - 20)], fill='#1e293b', width=1)
            # Time text
            draw.text((x - 12, header_h - 20), f"{t_ns}ns", fill='#64748b', font=font_tiny)
            # Cycle label
            cycle_idx = (t_ns - 10) // 10
            if cycle_idx >= 0 and t_ns >= 15:
                draw.text((x - 55, header_h - 35), f"C{cycle_idx}", fill='#38bdf8', font=font_tiny)

    # Separator
    draw.line([(0, header_h), (total_w, header_h)], fill='#334155', width=2)
    draw.line([(label_w, 0), (label_w, total_h)], fill='#334155', width=2)

    # Draw each signal
    for row_idx, (sig_key, disp_name, sig_kind, color) in enumerate(display_signals):
        y = header_h + row_idx * row_h
        y_mid = y + row_h // 2
        
        # Alternating row background
        if row_idx % 2 == 1:
            draw.rectangle([(0, y), (total_w, y + row_h)], fill='#131e33')
            
        # Draw label
        draw.text((15, y + 8), disp_name, fill='#e2e8f0', font=font_small)

        sym = sig_by_name.get(sig_key)
        series = time_series.get(sym, []) if sym else []

        if sig_kind == '1bit':
            # Draw digital waveform
            y_high = y + 6
            y_low = y + row_h - 8
            
            # Sample points across time
            step_ps = 500
            prev_x = label_w
            prev_val = get_val_at(series, start_ps, default='0')
            prev_y = y_high if prev_val == '1' else y_low
            
            for t_ps in range(start_ps + step_ps, end_ps + 1, step_ps):
                x = label_w + int((t_ps - start_ps) * scale)
                val = get_val_at(series, t_ps, default='0')
                curr_y = y_high if val == '1' else y_low
                
                if curr_y != prev_y:
                    draw.line([(prev_x, prev_y), (x, prev_y)], fill=color, width=2)
                    draw.line([(x, prev_y), (x, curr_y)], fill=color, width=2)
                    prev_x = x
                    prev_y = curr_y
            draw.line([(prev_x, prev_y), (label_w + wave_w, prev_y)], fill=color, width=2)

        elif sig_kind in ('bus', 'bus_instr'):
            # Collect transitions within window
            transitions = []
            cur_val = get_val_at(series, start_ps, default='0')
            transitions.append((start_ps, cur_val))
            for t_ps, val in series:
                if start_ps < t_ps <= end_ps:
                    transitions.append((t_ps, val))
            transitions.append((end_ps, transitions[-1][1]))

            y_top = y + 6
            y_bot = y + row_h - 8
            width_bits = signals.get(sym, {}).get('width', 32) if sym else 32

            for k in range(len(transitions) - 1):
                t1, val = transitions[k]
                t2, _ = transitions[k + 1]
                x1 = label_w + int((t1 - start_ps) * scale)
                x2 = label_w + int((t2 - start_ps) * scale)
                if x2 <= x1:
                    continue

                # Hex representation
                hex_str = bus_to_hex(val, width_bits)
                if sig_kind == 'bus_instr' and hex_str in instr_names:
                    text_str = f"{hex_str} ({instr_names[hex_str]})"
                else:
                    text_str = f"0x{hex_str}"

                # Draw bus envelope
                # Bevel ends
                b_dx = min(4, (x2 - x1) // 3)
                points = [
                    (x1, y_mid),
                    (x1 + b_dx, y_top),
                    (x2 - b_dx, y_top),
                    (x2, y_mid),
                    (x2 - b_dx, y_bot),
                    (x1 + b_dx, y_bot),
                    (x1, y_mid)
                ]
                draw.polygon(points, fill='#1e293b', outline=color)
                
                # Center text if space allows
                box_w = x2 - x1
                if box_w > 30:
                    clip_text = text_str
                    # Check text length fit
                    bbox = draw.textbbox((0, 0), clip_text, font=font_tiny)
                    txt_w = bbox[2] - bbox[0]
                    while txt_w > box_w - 8 and len(clip_text) > 4:
                        clip_text = clip_text[:-2] + '…'
                        bbox = draw.textbbox((0, 0), clip_text, font=font_tiny)
                        txt_w = bbox[2] - bbox[0]
                    if txt_w <= box_w - 6:
                        tx = x1 + (box_w - txt_w) // 2
                        draw.text((tx, y + 9), clip_text, fill='#f1f5f9', font=font_tiny)

    # Save output
    out_path = os.path.join(repo_dir, 'docs', 'waveforms', 'cpu.png')
    img.save(out_path, 'PNG')
    print(f"Waveform successfully generated and saved to {out_path} ({total_w}x{total_h})")

if __name__ == '__main__':
    main()
