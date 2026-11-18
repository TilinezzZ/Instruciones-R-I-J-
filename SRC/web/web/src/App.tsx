import { useState, useEffect } from 'react'
import { Navbar, type NavRoute, type GlobalInstruction } from './components/Navbar'
import { DatapathView } from './views/DatapathView'
import { ControlUnitView } from './views/ControlUnitView'
import { TypeRView } from './views/TypeRView'
import { LwView } from './views/LwView'
import { TypeJView } from './views/TypeJView'
import { CompareView } from './views/CompareView'
import { InstructionFormats } from './components/InstructionFormats'
import { HelpModal } from './components/HelpModal'
import { sounds } from './utils/audio'

export function App() {
  // 1. Manejo de Rutas compatible con Vercel y Browser History
  const parseRouteFromLocation = (): NavRoute => {
    if (typeof window === 'undefined') return 'datapath'
    const path = window.location.pathname.toLowerCase()
    const hash = window.location.hash.toLowerCase()

    if (path.includes('control') || hash.includes('control')) return 'control'
    if (path.includes('tipo-r') || hash.includes('tipo-r')) return 'tipo-r'
    if (path.includes('lw') || hash.includes('lw')) return 'lw'
    if (path.includes('tipo-j') || hash.includes('tipo-j')) return 'tipo-j'
    if (path.includes('comparar') || hash.includes('comparar')) return 'comparar'
    return 'datapath'
  }

  const [currentRoute, setCurrentRoute] = useState<NavRoute>(parseRouteFromLocation)

  // Escuchar eventos de navegación de retroceso/avance
  useEffect(() => {
    const handlePopState = () => {
      setCurrentRoute(parseRouteFromLocation())
    }
    window.addEventListener('popstate', handlePopState)
    return () => window.removeEventListener('popstate', handlePopState)
  }, [])

  const handleNavigate = (route: NavRoute) => {
    setCurrentRoute(route)
    const targetPath =
      route === 'datapath' ? '/' : `/${route}`
    if (window.location.pathname !== targetPath) {
      window.history.pushState(null, '', targetPath)
    }
  }

  // 2. Estado de Tema (Claro / Oscuro)
  const [theme, setTheme] = useState<'dark' | 'light'>(() => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('mips_theme')
      if (saved === 'light' || saved === 'dark') return saved
    }
    return 'dark'
  })

  useEffect(() => {
    if (theme === 'light') {
      document.documentElement.classList.add('light')
      document.documentElement.classList.remove('dark')
    } else {
      document.documentElement.classList.add('dark')
      document.documentElement.classList.remove('light')
    }
    localStorage.setItem('mips_theme', theme)
  }, [theme])

  const toggleTheme = () => {
    setTheme((prev) => (prev === 'dark' ? 'light' : 'dark'))
  }

  // 3. Selector Global de Instrucción
  const [globalInstruction, setGlobalInstruction] = useState<GlobalInstruction>('R')

  // 4. Audio
  const [soundEnabled, setSoundEnabled] = useState<boolean>(true)
  const toggleSound = () => {
    const s = sounds.toggleSound()
    setSoundEnabled(s)
  }

  // 5. Modales
  const [formatsOpen, setFormatsOpen] = useState<boolean>(false)
  const [helpOpen, setHelpOpen] = useState<boolean>(false)

  return (
    <div className={`min-h-screen flex flex-col font-sans transition-colors ${
      theme === 'light'
        ? 'bg-slate-100 text-slate-800'
        : 'bg-circuit-grid text-slate-100'
    }`}>
      {/* 1. Barra de Navegación Superior */}
      <Navbar
        currentRoute={currentRoute}
        onNavigate={handleNavigate}
        theme={theme}
        onToggleTheme={toggleTheme}
        soundEnabled={soundEnabled}
        onToggleSound={toggleSound}
        globalInstruction={globalInstruction}
        onSelectGlobalInstruction={setGlobalInstruction}
        onOpenFormats={() => setFormatsOpen(true)}
        onOpenHelp={() => setHelpOpen(true)}
      />

      {/* 2. Vista Activa */}
      <div className="flex-1 flex flex-col">
        {currentRoute === 'datapath' && (
          <DatapathView theme={theme} globalInstruction={globalInstruction} />
        )}

        {currentRoute === 'control' && (
          <ControlUnitView theme={theme} />
        )}

        {currentRoute === 'tipo-r' && (
          <TypeRView theme={theme} />
        )}

        {currentRoute === 'lw' && (
          <LwView theme={theme} />
        )}

        {currentRoute === 'tipo-j' && (
          <TypeJView theme={theme} />
        )}

        {currentRoute === 'comparar' && (
          <CompareView theme={theme} />
        )}
      </div>

      {/* 3. Modales Globales */}
      <InstructionFormats
        isOpen={formatsOpen}
        onClose={() => setFormatsOpen(false)}
      />

      <HelpModal
        isOpen={helpOpen}
        onClose={() => setHelpOpen(false)}
      />
    </div>
  )
}

export default App
