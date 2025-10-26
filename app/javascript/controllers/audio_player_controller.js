import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-player"
export default class extends Controller {
  static targets = [
    "audio",
    "playButton", 
    "playIcon",
    "pauseIcon",
    "progressBar",
    "currentTime",
    "totalTime",
    "volumeControl",
    "volumeDisplay",
    "liveRegion",
    "loadingOverlay",
    "errorMessage",
    "controls"
  ]

  static values = {
    recordingUrl: String,
    seekStep: { type: Number, default: 5 },
    volumeStep: { type: Number, default: 0.1 }
  }

  connect() {
    this.audioElement = this.audioTarget
    this.isPlaying = false
    this.isLoading = true
    this.hasErrored = false
    
    // Set up audio event listeners
    this.audioElement.addEventListener('timeupdate', () => this.updateProgress())
    
    // Global keyboard handler for this player instance
    this.boundHandleKeydown = (e) => this.handleGlobalKeydown(e)
    this.element.addEventListener('keydown', this.boundHandleKeydown)
  }

  disconnect() {
    // Clean up: pause audio, remove listeners
    if (this.audioElement) {
      this.audioElement.pause()
    }
    this.element.removeEventListener('keydown', this.boundHandleKeydown)
  }

  // Toggle play/pause
  togglePlay(event) {
    event?.preventDefault()
    
    if (!this.audioElement) return
    
    if (this.isPlaying) {
      this.pause()
    } else {
      this.play()
    }
  }

  play() {
    if (!this.audioElement) return
    
    this.audioElement.play().then(() => {
      this.isPlaying = true
      this.updateButtonState()
      this.announceState("Playing recording")
    }).catch((error) => {
      console.error("Audio play failed:", error)
      this.handleError()
    })
  }

  pause() {
    if (!this.audioElement) return
    
    this.audioElement.pause()
    this.isPlaying = false
    this.updateButtonState()
    this.announceState("Paused")
  }

  // Seek to position on progress bar click
  seek(event) {
    if (!this.audioElement) return
    
    const seekTime = (event.target.value / 100) * this.audioElement.duration
    this.audioElement.currentTime = seekTime
    this.updateProgress()
  }

  // Keyboard controls
  handleKeydown(event) {
    // Focus on progress bar - arrow keys work natively for slider
    if (event.target === this.progressBarTarget) {
      return // Let native slider behavior handle
    }
    
    // Prevent default for arrow keys to avoid page scroll when in this controller context
    if (['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown'].includes(event.key)) {
      event.preventDefault()
    }
  }

  handleGlobalKeydown(event) {
    // Only handle keys if player is focused or contains focus
    if (!this.element.contains(document.activeElement)) {
      return
    }

    // Space bar - play/pause
    if (event.key === ' ' || event.key === 'Spacebar') {
      event.preventDefault()
      this.togglePlay(event)
      return
    }

    // Left Arrow - rewind
    if (event.key === 'ArrowLeft') {
      event.preventDefault()
      this.seekBackward()
      return
    }

    // Right Arrow - fast forward
    if (event.key === 'ArrowRight') {
      event.preventDefault()
      this.seekForward()
      return
    }

    // Up Arrow - volume up
    if (event.key === 'ArrowUp') {
      event.preventDefault()
      this.volumeUp()
      return
    }

    // Down Arrow - volume down
    if (event.key === 'ArrowDown') {
      event.preventDefault()
      this.volumeDown()
      return
    }
  }

  seekBackward() {
    if (!this.audioElement || !this.audioElement.duration) return
    
    const newTime = Math.max(0, this.audioElement.currentTime - this.seekStepValue)
    this.audioElement.currentTime = newTime
    this.updateProgress()
    this.announceState(`Rewound ${this.seekStepValue} seconds`)
  }

  seekForward() {
    if (!this.audioElement || !this.audioElement.duration) return
    
    const newTime = Math.min(
      this.audioElement.duration,
      this.audioElement.currentTime + this.seekStepValue
    )
    this.audioElement.currentTime = newTime
    this.updateProgress()
    this.announceState(`Skipped forward ${this.seekStepValue} seconds`)
  }

  updateVolume(event) {
    if (!this.audioElement || !this.volumeDisplayTarget) return
    
    const volume = parseFloat(event.target.value)
    this.audioElement.volume = volume
    this.updateVolumeDisplay(volume)
  }

  volumeUp() {
    if (!this.audioElement || !this.volumeControlTarget) return
    
    const newVolume = Math.min(1, this.audioElement.volume + this.volumeStepValue)
    this.audioElement.volume = newVolume
    this.volumeControlTarget.value = newVolume
    this.updateVolumeDisplay(newVolume)
    this.announceState(`Volume increased to ${Math.round(newVolume * 100)}%`)
  }

  volumeDown() {
    if (!this.audioElement || !this.volumeControlTarget) return
    
    const newVolume = Math.max(0, this.audioElement.volume - this.volumeStepValue)
    this.audioElement.volume = newVolume
    this.volumeControlTarget.value = newVolume
    this.updateVolumeDisplay(newVolume)
    this.announceState(`Volume decreased to ${Math.round(newVolume * 100)}%`)
  }

  updateVolumeDisplay(volume) {
    if (!this.volumeDisplayTarget) return
    this.volumeDisplayTarget.textContent = `${Math.round(volume * 100)}%`
  }

  // Called on audio timeupdate event
  updateProgress() {
    if (!this.audioElement || !this.progressBarTarget || !this.currentTimeTarget) return
    
    const current = this.audioElement.currentTime
    const duration = this.audioElement.duration
    
    if (duration) {
      const progress = (current / duration) * 100
      this.progressBarTarget.value = progress
      this.progressBarTarget.setAttribute('aria-valuenow', progress)
      
      this.currentTimeTarget.textContent = this.formatTime(current)
    }
  }

  // When audio metadata is loaded
  handleLoadedMetadata() {
    if (!this.audioElement) return
    
    this.isLoading = false
    
    // Hide loading overlay
    if (this.hasLoadingOverlayTarget) {
      this.loadingOverlayTarget.classList.add('hidden')
    }
    
    // Show controls
    if (this.hasControlsTarget) {
      this.controlsTarget.classList.remove('hidden')
    }
    
    // Update total time
    if (this.hasTotalTimeTarget) {
      this.totalTimeTarget.textContent = this.formatTime(this.audioElement.duration)
    }
    
    // Set initial volume display
    if (this.hasVolumeDisplayTarget && this.hasVolumeControlTarget) {
      this.updateVolumeDisplay(this.audioElement.volume)
    }
    
    this.announceState("Audio ready to play")
  }

  handleError() {
    this.hasErrored = true
    this.isLoading = false
    
    // Hide loading overlay
    if (this.hasLoadingOverlayTarget) {
      this.loadingOverlayTarget.classList.add('hidden')
    }
    
    // Hide controls
    if (this.hasControlsTarget) {
      this.controlsTarget.classList.add('hidden')
    }
    
    // Show error message
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.classList.remove('hidden')
    }
    
    this.announceState("Error loading recording")
  }

  handleEnded() {
    this.isPlaying = false
    this.updateButtonState()
    this.announceState("Recording finished")
  }

  retry() {
    if (!this.audioElement) return
    
    this.hasErrored = false
    this.isLoading = true
    
    // Show loading overlay
    if (this.hasLoadingOverlayTarget) {
      this.loadingOverlayTarget.classList.remove('hidden')
    }
    
    // Hide error message
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.classList.add('hidden')
    }
    
    // Reload audio element
    this.audioElement.load()
    this.audioElement.play().catch(() => {
      this.handleError()
    })
  }

  updateButtonState() {
    if (!this.hasPlayButtonTarget) return
    
    const playIcon = this.hasPlayIconTarget ? this.playIconTarget : null
    const pauseIcon = this.hasPauseIconTarget ? this.pauseIconTarget : null
    
    if (this.isPlaying) {
      // Show pause icon
      if (playIcon) playIcon.classList.add('hidden')
      if (pauseIcon) pauseIcon.classList.remove('hidden')
      this.playButtonTarget.setAttribute('aria-label', 'Pause recording')
    } else {
      // Show play icon
      if (playIcon) playIcon.classList.remove('hidden')
      if (pauseIcon) pauseIcon.classList.add('hidden')
      this.playButtonTarget.setAttribute('aria-label', 'Play recording')
    }
  }

  announceState(message) {
    if (!this.hasLiveRegionTarget) return
    this.liveRegionTarget.textContent = message
    
    // Clear after a moment
    setTimeout(() => {
      if (this.hasLiveRegionTarget) {
        this.liveRegionTarget.textContent = ''
      }
    }, 1000)
  }

  formatTime(seconds) {
    if (!seconds || isNaN(seconds)) return "0:00"
    
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    const s = Math.floor(seconds % 60)
    
    if (h > 0) {
      return `${h}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`
    } else {
      return `${m}:${String(s).padStart(2, '0')}`
    }
  }
}

