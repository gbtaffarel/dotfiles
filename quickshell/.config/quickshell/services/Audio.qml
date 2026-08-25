pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick 6.10

Singleton {
    id: root
    
    // Bind PipeWire nodes with PwObjectTracker so they are not unbound
    PwObjectTracker {
        objects: [
            Pipewire.defaultAudioSink,
            Pipewire.defaultAudioSource
        ]
    }
    
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    
    readonly property bool sinkReady: sink !== null && sink.audio !== null && sink.ready
    readonly property bool sourceReady: source !== null && source.audio !== null && source.ready
    
    property bool manualMuted: false
    property real manualVolume: 0.85
    
    readonly property bool muted: sinkReady ? (sink.audio.muted ?? manualMuted) : manualMuted
    readonly property real volume: {
        if (sinkReady && sink.audio && sink.audio.volume !== undefined && sink.audio.volume !== null && !isNaN(sink.audio.volume)) {
            return Math.max(0, Math.min(1.5, sink.audio.volume));
        }
        return manualVolume;
    }
    
    readonly property int percentage: Math.round(volume * 100)
    readonly property string icon: muted ? "" : (percentage < 50 ? "" : "")
    
    // Background processes for wpctl operations
    Process {
        id: setVolProc
    }
    
    Process {
        id: setMuteProc
    }
    
    Process {
        id: syncVolProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim();
                // Format: "Volume: 0.85" or "Volume: 0.85 [MUTED]"
                if (out.startsWith("Volume:")) {
                    const parts = out.split(/\s+/);
                    if (parts.length >= 2) {
                        const val = parseFloat(parts[1]);
                        if (!isNaN(val)) {
                            root.manualVolume = val;
                        }
                    }
                    root.manualMuted = out.includes("[MUTED]");
                }
            }
        }
    }
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: syncVolProc.running = true
    }
    
    Component.onCompleted: {
        syncVolProc.running = true;
    }
    
    function setVolume(newVolume: real): void {
        const clamped = Math.max(0, Math.min(1.5, newVolume));
        root.manualVolume = clamped;
        root.manualMuted = false;
        
        if (sinkReady && sink.audio) {
            sink.audio.muted = false;
            sink.audio.volume = clamped;
        }
        
        setVolProc.exec(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", clamped.toFixed(2)]);
    }
    
    function toggleMute(): void {
        root.manualMuted = !root.manualMuted;
        
        if (sinkReady && sink.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
        
        setMuteProc.exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
    }
    
    function increaseVolume(): void {
        const next = Math.min(1.5, volume + 0.05);
        setVolume(next);
    }
    
    function decreaseVolume(): void {
        const prev = Math.max(0, volume - 0.05);
        setVolume(prev);
    }
}
