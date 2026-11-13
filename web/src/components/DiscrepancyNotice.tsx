import React, { useState } from 'react'
import { AlertTriangle, ChevronDown, ChevronUp, BookOpen } from 'lucide-react'

export interface DiscrepancyItem {
  id: string
  title: string
  slideRef: string
  detectedIssue: string
  solutionApplied: string
}

export const DISCREPANCIES: DiscrepancyItem[] = [
  {
    id: 'en_br_vs_regwrite',
    title: 'Señal en_BR vs RegWrite',
    slideRef: 'Diapositiva 17 vs Diapositivas 18-22',
    detectedIssue: 'La Diapositiva 17 etiqueta la señal de habilitación de escritura en registros como "en_BR" (Enable Banco de Registros), mientras que las Diapositivas 18 a 22 emplean la nomenclatura estándar en inglés "RegWrite".',
    solutionApplied: 'En toda la plataforma se presentan como equivalentes: en_BR ≡ RegWrite. Se preserva en_BR para concordar con el dibujo RTL original y se aclara que activa la escritura en el Banco de Registros.'
  },
  {
    id: 'alu_control_bits',
    title: 'Ancho de bits de ALU Control (3 bits vs 4 bits)',
    slideRef: 'Diapositiva 17 vs Diapositiva 23',
    detectedIssue: 'La Diapositiva 17 dibuja la línea de control que alimenta a la ALU con 3 bits (010, 110, etc.), mientras que la tabla formal de ALU Control en la Diapositiva 23 utiliza códigos de 4 bits (0010, 0110, 0000, 0001, 0111).',
    solutionApplied: 'Se adoptan formalmente los 4 bits de la tabla de la Diapositiva 23 (0010 para ADD, 0110 para SUB, etc.) y se muestra en la inspección la correlación directa con los 3 bits menos significativos del diagrama RTL.'
  },
  {
    id: 'sw_semantics_slide27',
    title: 'Título y Sintaxis de SW en Diapositiva 27',
    slideRef: 'Diapositiva 27 (Instrucción SW)',
    detectedIssue: 'La Diapositiva 27 duplica por error tipográfico el título y formato de LW ("LW $RT, $RS, #offset").',
    solutionApplied: 'Se implementa la semántica y sintaxis formal correcta de Store Word: "sw $rt, offset($rs)" con transferencia "memory[GPR[rs] + offset] ← GPR[rt]" (flujo inverso a LW).'
  },
  {
    id: 'slide25_syntax_error',
    title: 'Sintaxis de LW en Diapositiva 25 (Set de Instrucciones)',
    slideRef: 'Diapositiva 25',
    detectedIssue: 'En el resumen del conjunto de instrucciones de la Diapositiva 25, la fila de LW tiene copiada la sintaxis de suma: "Add $rd, $rs, $rt".',
    solutionApplied: 'Se corrige visualmente mostrando la sintaxis real de Tipo I para cargas: "lw $rt, offset($rs)".'
  }
]

interface DiscrepancyNoticeProps {
  filterId?: string
}

export const DiscrepancyNotice: React.FC<DiscrepancyNoticeProps> = ({ filterId }) => {
  const [expanded, setExpanded] = useState<boolean>(false)

  const items = filterId ? DISCREPANCIES.filter((d) => d.id === filterId) : DISCREPANCIES

  return (
    <div className="w-full rounded-xl border border-amber-500/30 bg-amber-950/20 p-3 sm:p-4 text-xs transition-all shadow-sm">
      <div
        className="flex items-center justify-between cursor-pointer select-none"
        onClick={() => setExpanded(!expanded)}
      >
        <div className="flex items-center gap-2 text-amber-400 font-semibold">
          <AlertTriangle className="h-4 w-4 shrink-0 text-amber-400" />
          <span>
            Fe de Erratas y Discrepancias Académicas (Diapositivas 17 a 27)
          </span>
          <span className="text-[10px] font-mono px-1.5 py-0.5 rounded bg-amber-900/40 text-amber-300">
            {items.length} notas
          </span>
        </div>
        <button
          className="p-1 text-amber-400 hover:text-amber-200 transition-colors"
          aria-label={expanded ? 'Ocultar notas' : 'Ver notas'}
        >
          {expanded ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
        </button>
      </div>

      {expanded && (
        <div className="mt-3 space-y-3 pt-3 border-t border-amber-500/20 animate-in fade-in">
          {items.map((item) => (
            <div
              key={item.id}
              className="p-3 rounded-lg bg-slate-900/70 border border-slate-800 space-y-1.5"
            >
              <div className="flex flex-wrap items-center justify-between gap-1">
                <span className="font-bold text-white flex items-center gap-1.5">
                  <BookOpen className="h-3 w-3 text-cyan-400" />
                  {item.title}
                </span>
                <span className="font-mono text-[10px] text-amber-300/80 bg-amber-950/60 px-2 py-0.5 rounded border border-amber-800/40">
                  {item.slideRef}
                </span>
              </div>
              <p className="text-slate-300 leading-relaxed text-[11px]">
                <strong className="text-amber-300">Observación en lámina: </strong>
                {item.detectedIssue}
              </p>
              <p className="text-slate-300 leading-relaxed text-[11px]">
                <strong className="text-emerald-300">Criterio aplicado en app: </strong>
                {item.solutionApplied}
              </p>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
