// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum App {
    /// App
    internal static var name: String { return L10n.tr("Localizable", "app.name", fallback: "MC Teleprompter") }
    internal enum Tagline {
      /// Focus on your content.
      internal static var focus: String { return L10n.tr("Localizable", "app.tagline.focus", fallback: "Focus on your content.") }
      /// Easy teleprompter.
      internal static var prompting: String { return L10n.tr("Localizable", "app.tagline.prompting", fallback: "Easy teleprompter.") }
    }
  }
  internal enum Common {
    /// Cancel
    internal static var cancel: String { return L10n.tr("Localizable", "common.cancel", fallback: "Cancel") }
    /// Common
    internal static var loading: String { return L10n.tr("Localizable", "common.loading", fallback: "Loading...") }
    /// OK
    internal static var ok: String { return L10n.tr("Localizable", "common.ok", fallback: "OK") }
    /// Retry
    internal static var retry: String { return L10n.tr("Localizable", "common.retry", fallback: "Retry") }
    internal enum Error {
      /// Something went wrong. Please try again.
      internal static var message: String { return L10n.tr("Localizable", "common.error.message", fallback: "Something went wrong. Please try again.") }
      /// Error
      internal static var title: String { return L10n.tr("Localizable", "common.error.title", fallback: "Error") }
    }
    internal enum Success {
      /// Success
      internal static var title: String { return L10n.tr("Localizable", "common.success.title", fallback: "Success") }
    }
  }
  internal enum Football {
    /// Lineup Builder
    internal static var brand: String { return L10n.tr("Localizable", "football.brand", fallback: "Lineup Builder") }
    /// Football Lineup Builder
    internal static var `open`: String { return L10n.tr("Localizable", "football.open", fallback: "Lineup Builder") }
    /// Tactical board · Squad builder
    internal static var tagline: String { return L10n.tr("Localizable", "football.tagline", fallback: "Tactical board · Squad builder") }
    internal enum Editor {
      /// Bench
      internal static var bench: String { return L10n.tr("Localizable", "football.editor.bench", fallback: "Bench") }
      /// Bench players
      internal static var benchPlayers: String { return L10n.tr("Localizable", "football.editor.benchPlayers", fallback: "Bench players") }
      /// Draw
      internal static var draw: String { return L10n.tr("Localizable", "football.editor.draw", fallback: "Draw") }
      /// Edit Lineup
      internal static var editTitle: String { return L10n.tr("Localizable", "football.editor.editTitle", fallback: "Edit Lineup") }
      /// Empty
      internal static var emptySlot: String { return L10n.tr("Localizable", "football.editor.emptySlot", fallback: "Empty") }
      /// Loaded team "%@"
      internal static func importedTeam(_ p1: Any) -> String {
        return L10n.tr("Localizable", "football.editor.importedTeam", String(describing: p1), fallback: "Loaded team \"%@\"")
      }
      /// Import team
      internal static var importTeam: String { return L10n.tr("Localizable", "football.editor.importTeam", fallback: "Import team") }
      /// No saved teams yet. Create one in My Teams first.
      internal static var importTeamEmpty: String { return L10n.tr("Localizable", "football.editor.importTeamEmpty", fallback: "No saved teams yet. Create one in My Teams first.") }
      /// Redo
      internal static var redo: String { return L10n.tr("Localizable", "football.editor.redo", fallback: "Redo") }
      /// Save Lineup
      internal static var save: String { return L10n.tr("Localizable", "football.editor.save", fallback: "Save Lineup") }
      /// Lineup saved
      internal static var saved: String { return L10n.tr("Localizable", "football.editor.saved", fallback: "Lineup saved") }
      /// Lineup Editor
      internal static var title: String { return L10n.tr("Localizable", "football.editor.title", fallback: "Lineup Editor") }
      /// Undo
      internal static var undo: String { return L10n.tr("Localizable", "football.editor.undo", fallback: "Undo") }
      /// Untitled lineup
      internal static var untitled: String { return L10n.tr("Localizable", "football.editor.untitled", fallback: "Untitled lineup") }
      internal enum Settings {
        /// Tactical name
        internal static var nameLabel: String { return L10n.tr("Localizable", "football.editor.settings.nameLabel", fallback: "Tactical name") }
        /// Enter a name
        internal static var namePlaceholder: String { return L10n.tr("Localizable", "football.editor.settings.namePlaceholder", fallback: "Enter a name") }
        /// Name saved
        internal static var nameSaved: String { return L10n.tr("Localizable", "football.editor.settings.nameSaved", fallback: "Name saved") }
        /// Save
        internal static var save: String { return L10n.tr("Localizable", "football.editor.settings.save", fallback: "Save") }
        /// Tactical settings
        internal static var title: String { return L10n.tr("Localizable", "football.editor.settings.title", fallback: "Tactical settings") }
      }
      internal enum Tab {
        /// Formation
        internal static var formation: String { return L10n.tr("Localizable", "football.editor.tab.formation", fallback: "Formation") }
        /// Players
        internal static var players: String { return L10n.tr("Localizable", "football.editor.tab.players", fallback: "Players") }
        /// Tactics
        internal static var tactics: String { return L10n.tr("Localizable", "football.editor.tab.tactics", fallback: "Tactics") }
      }
      internal enum Tool {
        /// ARROWS
        internal static var arrows: String { return L10n.tr("Localizable", "football.editor.tool.arrows", fallback: "ARROWS") }
        /// FIELDS
        internal static var fields: String { return L10n.tr("Localizable", "football.editor.tool.fields", fallback: "FIELDS") }
        /// FORMATION
        internal static var formation: String { return L10n.tr("Localizable", "football.editor.tool.formation", fallback: "FORMATION") }
      }
    }
    internal enum Formation {
      /// Apply formation
      internal static var apply: String { return L10n.tr("Localizable", "football.formation.apply", fallback: "Apply formation") }
      /// Choose formation
      internal static var title: String { return L10n.tr("Localizable", "football.formation.title", fallback: "Choose formation") }
    }
    internal enum LineOptions {
      /// Color
      internal static var color: String { return L10n.tr("Localizable", "football.lineOptions.color", fallback: "Color") }
      /// Curved
      internal static var curved: String { return L10n.tr("Localizable", "football.lineOptions.curved", fallback: "Curved") }
      /// Dashed
      internal static var dashed: String { return L10n.tr("Localizable", "football.lineOptions.dashed", fallback: "Dashed") }
      /// Line type
      internal static var lineType: String { return L10n.tr("Localizable", "football.lineOptions.lineType", fallback: "Line type") }
      /// Pointer style
      internal static var pointer: String { return L10n.tr("Localizable", "football.lineOptions.pointer", fallback: "Pointer style") }
      /// Save
      internal static var save: String { return L10n.tr("Localizable", "football.lineOptions.save", fallback: "Save") }
      /// Solid
      internal static var solid: String { return L10n.tr("Localizable", "football.lineOptions.solid", fallback: "Solid") }
      /// Straight
      internal static var straight: String { return L10n.tr("Localizable", "football.lineOptions.straight", fallback: "Straight") }
      /// Line options
      internal static var title: String { return L10n.tr("Localizable", "football.lineOptions.title", fallback: "Line options") }
    }
    internal enum Lineups {
      /// %d d ago
      internal static func editedDaysAgo(_ p1: Int) -> String {
        return L10n.tr("Localizable", "football.lineups.editedDaysAgo", p1, fallback: "%d d ago")
      }
      /// %d h ago
      internal static func editedHoursAgo(_ p1: Int) -> String {
        return L10n.tr("Localizable", "football.lineups.editedHoursAgo", p1, fallback: "%d h ago")
      }
      /// %d min ago
      internal static func editedMinutesAgo(_ p1: Int) -> String {
        return L10n.tr("Localizable", "football.lineups.editedMinutesAgo", p1, fallback: "%d min ago")
      }
      /// Add to favorites
      internal static var favorite: String { return L10n.tr("Localizable", "football.lineups.favorite", fallback: "Add to favorites") }
      /// Premium — coming soon.
      internal static var premiumHint: String { return L10n.tr("Localizable", "football.lineups.premiumHint", fallback: "Premium — coming soon.") }
      /// Most recent
      internal static var sortRecent: String { return L10n.tr("Localizable", "football.lineups.sortRecent", fallback: "Most recent") }
      /// Sort lineups
      internal static var sortTitle: String { return L10n.tr("Localizable", "football.lineups.sortTitle", fallback: "Sort lineups") }
      /// My Lineups
      internal static var title: String { return L10n.tr("Localizable", "football.lineups.title", fallback: "My Lineups") }
      /// Remove from favorites
      internal static var unfavorite: String { return L10n.tr("Localizable", "football.lineups.unfavorite", fallback: "Remove from favorites") }
      internal enum Filter {
        /// All Teams
        internal static var allTeams: String { return L10n.tr("Localizable", "football.lineups.filter.allTeams", fallback: "All Teams") }
        /// Drafts
        internal static var drafts: String { return L10n.tr("Localizable", "football.lineups.filter.drafts", fallback: "Drafts") }
        /// Favorites
        internal static var favorites: String { return L10n.tr("Localizable", "football.lineups.filter.favorites", fallback: "Favorites") }
        /// Recent
        internal static var recent: String { return L10n.tr("Localizable", "football.lineups.filter.recent", fallback: "Recent") }
      }
      internal enum Sample {
        /// Counter Attack Setup
        internal static var counterAttack: String { return L10n.tr("Localizable", "football.lineups.sample.counterAttack", fallback: "Counter Attack Setup") }
        /// Dream Team 2024
        internal static var dreamTeam: String { return L10n.tr("Localizable", "football.lineups.sample.dreamTeam", fallback: "Dream Team 2024") }
        /// UCL Final Tactics
        internal static var uclFinal: String { return L10n.tr("Localizable", "football.lineups.sample.uclFinal", fallback: "UCL Final Tactics") }
      }
      internal enum Style {
        /// ATTACKING
        internal static var attacking: String { return L10n.tr("Localizable", "football.lineups.style.attacking", fallback: "ATTACKING") }
        /// BALANCED
        internal static var balanced: String { return L10n.tr("Localizable", "football.lineups.style.balanced", fallback: "BALANCED") }
        /// DEFENSIVE
        internal static var defensive: String { return L10n.tr("Localizable", "football.lineups.style.defensive", fallback: "DEFENSIVE") }
      }
    }
    internal enum Match {
      internal enum Action {
        /// End 1st half
        internal static var endFirstHalf: String { return L10n.tr("Localizable", "football.match.action.endFirstHalf", fallback: "End 1st half") }
        /// End match
        internal static var endMatch: String { return L10n.tr("Localizable", "football.match.action.endMatch", fallback: "End match") }
        /// End penalties
        internal static var endPenalties: String { return L10n.tr("Localizable", "football.match.action.endPenalties", fallback: "End penalties") }
        /// Start extra 2nd half
        internal static var startExtraSecond: String { return L10n.tr("Localizable", "football.match.action.startExtraSecond", fallback: "Start extra 2nd half") }
        /// Start match
        internal static var startMatch: String { return L10n.tr("Localizable", "football.match.action.startMatch", fallback: "Start match") }
        /// Start 2nd half
        internal static var startSecondHalf: String { return L10n.tr("Localizable", "football.match.action.startSecondHalf", fallback: "Start 2nd half") }
      }
      internal enum Create {
        /// Away team
        internal static var awayTeam: String { return L10n.tr("Localizable", "football.match.create.awayTeam", fallback: "Away team") }
        /// Create match
        internal static var confirm: String { return L10n.tr("Localizable", "football.match.create.confirm", fallback: "Create match") }
        /// Continue
        internal static var continueSetup: String { return L10n.tr("Localizable", "football.match.create.continueSetup", fallback: "Continue") }
        /// Half duration
        internal static var duration: String { return L10n.tr("Localizable", "football.match.create.duration", fallback: "Half duration") }
        /// Extra time
        internal static var extraTime: String { return L10n.tr("Localizable", "football.match.create.extraTime", fallback: "Extra time") }
        /// 1st half (min)
        internal static var firstHalf: String { return L10n.tr("Localizable", "football.match.create.firstHalf", fallback: "1st half (min)") }
        /// Home team
        internal static var homeTeam: String { return L10n.tr("Localizable", "football.match.create.homeTeam", fallback: "Home team") }
        /// “%@” is missing players for %d-a-side. Fill every slot in My Teams for this pitch size, or assign players in the next step.
        internal static func importIncomplete(_ p1: Any, _ p2: Int) -> String {
          return L10n.tr("Localizable", "football.match.create.importIncomplete", String(describing: p1), p2, fallback: "“%@” is missing players for %d-a-side. Fill every slot in My Teams for this pitch size, or assign players in the next step.")
        }
        /// Kick-off time
        internal static var kickoff: String { return L10n.tr("Localizable", "football.match.create.kickoff", fallback: "Kick-off time") }
        /// Penalty shootout
        internal static var penalty: String { return L10n.tr("Localizable", "football.match.create.penalty", fallback: "Penalty shootout") }
        /// %d-a-side
        internal static func pitchPlayers(_ p1: Int) -> String {
          return L10n.tr("Localizable", "football.match.create.pitchPlayers", p1, fallback: "%d-a-side")
        }
        /// Pitch size
        internal static var pitchSize: String { return L10n.tr("Localizable", "football.match.create.pitchSize", fallback: "Pitch size") }
        /// Remove imported team
        internal static var removeImported: String { return L10n.tr("Localizable", "football.match.create.removeImported", fallback: "Remove imported team") }
        /// Home %d/%d · Away %d/%d
        internal static func rosterProgress(_ p1: Int, _ p2: Int, _ p3: Int, _ p4: Int) -> String {
          return L10n.tr("Localizable", "football.match.create.rosterProgress", p1, p2, p3, p4, fallback: "Home %d/%d · Away %d/%d")
        }
        /// 2nd half (min)
        internal static var secondHalf: String { return L10n.tr("Localizable", "football.match.create.secondHalf", fallback: "2nd half (min)") }
        /// Team lineups
        internal static var setupTeams: String { return L10n.tr("Localizable", "football.match.create.setupTeams", fallback: "Team lineups") }
        /// Tap a position on the pitch or bench to assign a player.
        internal static var tapSlotHint: String { return L10n.tr("Localizable", "football.match.create.tapSlotHint", fallback: "Tap a position on the pitch or bench to assign a player.") }
        /// Imported: %@
        internal static func teamImported(_ p1: Any) -> String {
          return L10n.tr("Localizable", "football.match.create.teamImported", String(describing: p1), fallback: "Imported: %@")
        }
        /// Pitch %d/%d · Bench %d/%d
        internal static func teamRosterProgress(_ p1: Int, _ p2: Int, _ p3: Int, _ p4: Int) -> String {
          return L10n.tr("Localizable", "football.match.create.teamRosterProgress", p1, p2, p3, p4, fallback: "Pitch %d/%d · Bench %d/%d")
        }
        /// Teams
        internal static var teams: String { return L10n.tr("Localizable", "football.match.create.teams", fallback: "Teams") }
        /// Create match
        internal static var title: String { return L10n.tr("Localizable", "football.match.create.title", fallback: "Create match") }
        /// Assign a player to every position for both teams.
        internal static var validationPlayers: String { return L10n.tr("Localizable", "football.match.create.validationPlayers", fallback: "Assign a player to every position for both teams.") }
        /// Enter home and away team names.
        internal static var validationTeams: String { return L10n.tr("Localizable", "football.match.create.validationTeams", fallback: "Enter home and away team names.") }
      }
      internal enum Event {
        /// Goal
        internal static var goal: String { return L10n.tr("Localizable", "football.match.event.goal", fallback: "Goal") }
        /// Neutral
        internal static var neutral: String { return L10n.tr("Localizable", "football.match.event.neutral", fallback: "Neutral") }
        /// Penalty
        internal static var penalty: String { return L10n.tr("Localizable", "football.match.event.penalty", fallback: "Penalty") }
        /// Pen
        internal static var penaltyShort: String { return L10n.tr("Localizable", "football.match.event.penaltyShort", fallback: "Pen") }
        /// Red
        internal static var red: String { return L10n.tr("Localizable", "football.match.event.red", fallback: "Red") }
        /// Red card
        internal static var redCard: String { return L10n.tr("Localizable", "football.match.event.redCard", fallback: "Red card") }
        /// Sub
        internal static var sub: String { return L10n.tr("Localizable", "football.match.event.sub", fallback: "Sub") }
        /// Substitution
        internal static var substitution: String { return L10n.tr("Localizable", "football.match.event.substitution", fallback: "Substitution") }
        /// 2 yellows → red
        internal static var twoYellowsRed: String { return L10n.tr("Localizable", "football.match.event.twoYellowsRed", fallback: "2 yellows → red") }
        /// VAR check
        internal static var varReview: String { return L10n.tr("Localizable", "football.match.event.varReview", fallback: "VAR check") }
        /// VAR
        internal static var varShort: String { return L10n.tr("Localizable", "football.match.event.varShort", fallback: "VAR") }
        /// Yellow
        internal static var yellow: String { return L10n.tr("Localizable", "football.match.event.yellow", fallback: "Yellow") }
        /// Yellow card
        internal static var yellowCard: String { return L10n.tr("Localizable", "football.match.event.yellowCard", fallback: "Yellow card") }
      }
      internal enum Half {
        /// ET 1ST HALF
        internal static var extraFirst: String { return L10n.tr("Localizable", "football.match.half.extraFirst", fallback: "ET 1ST HALF") }
        /// ET 2ND HALF
        internal static var extraSecond: String { return L10n.tr("Localizable", "football.match.half.extraSecond", fallback: "ET 2ND HALF") }
        /// 1ST HALF
        internal static var first: String { return L10n.tr("Localizable", "football.match.half.first", fallback: "1ST HALF") }
        /// PENALTIES
        internal static var penalties: String { return L10n.tr("Localizable", "football.match.half.penalties", fallback: "PENALTIES") }
        /// 2ND HALF
        internal static var second: String { return L10n.tr("Localizable", "football.match.half.second", fallback: "2ND HALF") }
      }
      internal enum Live {
        /// Add event
        internal static var addEvent: String { return L10n.tr("Localizable", "football.match.live.addEvent", fallback: "Add event") }
        /// End this match now?
        internal static var finishConfirm: String { return L10n.tr("Localizable", "football.match.live.finishConfirm", fallback: "End this match now?") }
        /// End match
        internal static var finishMatch: String { return L10n.tr("Localizable", "football.match.live.finishMatch", fallback: "End match") }
        /// No players available (sent off or empty squad).
        internal static var noSelectablePlayers: String { return L10n.tr("Localizable", "football.match.live.noSelectablePlayers", fallback: "No players available (sent off or empty squad).") }
        /// Select player
        internal static var pickPlayer: String { return L10n.tr("Localizable", "football.match.live.pickPlayer", fallback: "Select player") }
        internal enum Tab {
          /// Events
          internal static var events: String { return L10n.tr("Localizable", "football.match.live.tab.events", fallback: "Events") }
          /// Lineups
          internal static var lineups: String { return L10n.tr("Localizable", "football.match.live.tab.lineups", fallback: "Lineups") }
        }
      }
      internal enum Phase {
        /// Extra time — 1st half
        internal static var extraFirst: String { return L10n.tr("Localizable", "football.match.phase.extraFirst", fallback: "Extra time — 1st half") }
        /// Extra time break
        internal static var extraHalftime: String { return L10n.tr("Localizable", "football.match.phase.extraHalftime", fallback: "Extra time break") }
        /// Extra time — 2nd half
        internal static var extraSecond: String { return L10n.tr("Localizable", "football.match.phase.extraSecond", fallback: "Extra time — 2nd half") }
        /// Extra time stoppage
        internal static var extraSecondStoppage: String { return L10n.tr("Localizable", "football.match.phase.extraSecondStoppage", fallback: "Extra time stoppage") }
        /// Full time
        internal static var finished: String { return L10n.tr("Localizable", "football.match.phase.finished", fallback: "Full time") }
        /// 1st half
        internal static var firstHalf: String { return L10n.tr("Localizable", "football.match.phase.firstHalf", fallback: "1st half") }
        /// 1st half stoppage time
        internal static var firstHalfStoppage: String { return L10n.tr("Localizable", "football.match.phase.firstHalfStoppage", fallback: "1st half stoppage time") }
        /// Half-time break
        internal static var halftime: String { return L10n.tr("Localizable", "football.match.phase.halftime", fallback: "Half-time break") }
        /// Live
        internal static var live: String { return L10n.tr("Localizable", "football.match.phase.live", fallback: "Live") }
        /// Penalty shootout
        internal static var penalties: String { return L10n.tr("Localizable", "football.match.phase.penalties", fallback: "Penalty shootout") }
        /// Ready to kick off
        internal static var scheduled: String { return L10n.tr("Localizable", "football.match.phase.scheduled", fallback: "Ready to kick off") }
        /// 2nd half
        internal static var secondHalf: String { return L10n.tr("Localizable", "football.match.phase.secondHalf", fallback: "2nd half") }
        /// 2nd half stoppage time
        internal static var secondHalfStoppage: String { return L10n.tr("Localizable", "football.match.phase.secondHalfStoppage", fallback: "2nd half stoppage time") }
      }
      internal enum Timeline {
        /// No events this half
        internal static var emptyHalf: String { return L10n.tr("Localizable", "football.match.timeline.emptyHalf", fallback: "No events this half") }
      }
    }
    internal enum Matches {
      /// No scores yet. Tap + to enter a result.
      internal static var empty: String { return L10n.tr("Localizable", "football.matches.empty", fallback: "No scores yet. Tap + to enter a result.") }
      /// Record match results.
      internal static var subtitle: String { return L10n.tr("Localizable", "football.matches.subtitle", fallback: "Record match results.") }
      /// Scores
      internal static var title: String { return L10n.tr("Localizable", "football.matches.title", fallback: "Scores") }
    }
    internal enum PitchOptions {
      /// Save
      internal static var save: String { return L10n.tr("Localizable", "football.pitchOptions.save", fallback: "Save") }
      /// Show grid
      internal static var showGrid: String { return L10n.tr("Localizable", "football.pitchOptions.showGrid", fallback: "Show grid") }
      /// Pitch options
      internal static var title: String { return L10n.tr("Localizable", "football.pitchOptions.title", fallback: "Pitch options") }
      internal enum Style {
        /// Full pitch
        internal static var full: String { return L10n.tr("Localizable", "football.pitchOptions.style.full", fallback: "Full pitch") }
        /// Futsal
        internal static var futsal: String { return L10n.tr("Localizable", "football.pitchOptions.style.futsal", fallback: "Futsal") }
        /// Half pitch
        internal static var half: String { return L10n.tr("Localizable", "football.pitchOptions.style.half", fallback: "Half pitch") }
      }
    }
    internal enum Players {
      /// Tap to choose a photo
      internal static var avatarHint: String { return L10n.tr("Localizable", "football.players.avatarHint", fallback: "Tap to choose a photo") }
      /// Create new player
      internal static var create: String { return L10n.tr("Localizable", "football.players.create", fallback: "Create new player") }
      /// Delete
      internal static var deleteConfirm: String { return L10n.tr("Localizable", "football.players.deleteConfirm", fallback: "Delete") }
      /// Create player
      internal static var editorTitle: String { return L10n.tr("Localizable", "football.players.editorTitle", fallback: "Create player") }
      /// 1–99 (optional)
      internal static var jerseyPlaceholder: String { return L10n.tr("Localizable", "football.players.jerseyPlaceholder", fallback: "1–99 (optional)") }
      /// Shirt number
      internal static var jerseyTitle: String { return L10n.tr("Localizable", "football.players.jerseyTitle", fallback: "Shirt number") }
      /// No players yet. Tap + to create a player.
      internal static var libraryEmpty: String { return L10n.tr("Localizable", "football.players.libraryEmpty", fallback: "No players yet. Tap + to create a player.") }
      /// My Players
      internal static var libraryTitle: String { return L10n.tr("Localizable", "football.players.libraryTitle", fallback: "My Players") }
      /// Player name
      internal static var namePlaceholder: String { return L10n.tr("Localizable", "football.players.namePlaceholder", fallback: "Player name") }
      /// Position
      internal static var positionTitle: String { return L10n.tr("Localizable", "football.players.positionTitle", fallback: "Position") }
      /// Save player
      internal static var save: String { return L10n.tr("Localizable", "football.players.save", fallback: "Save player") }
      /// Player saved.
      internal static var saved: String { return L10n.tr("Localizable", "football.players.saved", fallback: "Player saved.") }
      /// Search players
      internal static var search: String { return L10n.tr("Localizable", "football.players.search", fallback: "Search players") }
      /// Select player
      internal static var title: String { return L10n.tr("Localizable", "football.players.title", fallback: "Select player") }
      /// Shirt number must be between 1 and 99.
      internal static var validationJersey: String { return L10n.tr("Localizable", "football.players.validationJersey", fallback: "Shirt number must be between 1 and 99.") }
      /// Enter a player name.
      internal static var validationName: String { return L10n.tr("Localizable", "football.players.validationName", fallback: "Enter a player name.") }
      internal enum Filter {
        /// Club
        internal static var club: String { return L10n.tr("Localizable", "football.players.filter.club", fallback: "Club") }
        /// Nation
        internal static var nation: String { return L10n.tr("Localizable", "football.players.filter.nation", fallback: "Nation") }
        /// Position
        internal static var position: String { return L10n.tr("Localizable", "football.players.filter.position", fallback: "Position") }
        /// Rating
        internal static var rating: String { return L10n.tr("Localizable", "football.players.filter.rating", fallback: "Rating") }
      }
      internal enum Picker {
        /// Remove from this position
        internal static var clearPosition: String { return L10n.tr("Localizable", "football.players.picker.clearPosition", fallback: "Remove from this position") }
        /// On bench
        internal static var onBench: String { return L10n.tr("Localizable", "football.players.picker.onBench", fallback: "On bench") }
        /// On field
        internal static var onPitch: String { return L10n.tr("Localizable", "football.players.picker.onPitch", fallback: "On field") }
        /// This slot
        internal static var thisPosition: String { return L10n.tr("Localizable", "football.players.picker.thisPosition", fallback: "This slot") }
      }
      internal enum Position {
        /// DEF
        internal static var def: String { return L10n.tr("Localizable", "football.players.position.def", fallback: "DEF") }
        /// FWD
        internal static var fwd: String { return L10n.tr("Localizable", "football.players.position.fwd", fallback: "FWD") }
        /// GK
        internal static var gk: String { return L10n.tr("Localizable", "football.players.position.gk", fallback: "GK") }
        /// MID
        internal static var mid: String { return L10n.tr("Localizable", "football.players.position.mid", fallback: "MID") }
      }
    }
    internal enum Score {
      /// Away goals
      internal static var awayGoals: String { return L10n.tr("Localizable", "football.score.awayGoals", fallback: "Away goals") }
      /// Edit score
      internal static var editTitle: String { return L10n.tr("Localizable", "football.score.editTitle", fallback: "Edit score") }
      /// Home goals
      internal static var homeGoals: String { return L10n.tr("Localizable", "football.score.homeGoals", fallback: "Home goals") }
      /// Save
      internal static var save: String { return L10n.tr("Localizable", "football.score.save", fallback: "Save") }
      /// Score
      internal static var scoreSection: String { return L10n.tr("Localizable", "football.score.scoreSection", fallback: "Score") }
      /// Enter score
      internal static var title: String { return L10n.tr("Localizable", "football.score.title", fallback: "Enter score") }
      /// Enter home and away team names.
      internal static var validationTeams: String { return L10n.tr("Localizable", "football.score.validationTeams", fallback: "Enter home and away team names.") }
    }
    internal enum Settings {
      /// Appearance
      internal static var appearance: String { return L10n.tr("Localizable", "football.settings.appearance", fallback: "Appearance") }
      /// App version
      internal static var appVersion: String { return L10n.tr("Localizable", "football.settings.appVersion", fallback: "App version") }
      /// Clear data
      internal static var clearData: String { return L10n.tr("Localizable", "football.settings.clearData", fallback: "Clear data") }
      /// Clear
      internal static var clearDataConfirm: String { return L10n.tr("Localizable", "football.settings.clearDataConfirm", fallback: "Clear") }
      /// This removes all lineups, teams, players, and matches saved on this device. This cannot be undone.
      internal static var clearDataMessage: String { return L10n.tr("Localizable", "football.settings.clearDataMessage", fallback: "This removes all lineups, teams, players, and matches saved on this device. This cannot be undone.") }
      /// Data cleared.
      internal static var clearDataSuccess: String { return L10n.tr("Localizable", "football.settings.clearDataSuccess", fallback: "Data cleared.") }
      /// Clear all data?
      internal static var clearDataTitle: String { return L10n.tr("Localizable", "football.settings.clearDataTitle", fallback: "Clear all data?") }
      /// General
      internal static var generalSection: String { return L10n.tr("Localizable", "football.settings.generalSection", fallback: "General") }
      /// Language
      internal static var language: String { return L10n.tr("Localizable", "football.settings.language", fallback: "Language") }
      /// Link is not available yet.
      internal static var linkUnavailable: String { return L10n.tr("Localizable", "football.settings.linkUnavailable", fallback: "Link is not available yet.") }
      /// Manage players
      internal static var managePlayers: String { return L10n.tr("Localizable", "football.settings.managePlayers", fallback: "Manage players") }
      /// Create players with name, photo and shirt number.
      internal static var managePlayersHint: String { return L10n.tr("Localizable", "football.settings.managePlayersHint", fallback: "Create players with name, photo and shirt number.") }
      /// Policy
      internal static var policy: String { return L10n.tr("Localizable", "football.settings.policy", fallback: "Policy") }
      /// Privacy
      internal static var privacy: String { return L10n.tr("Localizable", "football.settings.privacy", fallback: "Privacy") }
      /// Rate us
      internal static var rateUs: String { return L10n.tr("Localizable", "football.settings.rateUs", fallback: "Rate us") }
      /// Squad
      internal static var squadSection: String { return L10n.tr("Localizable", "football.settings.squadSection", fallback: "Squad") }
      /// Settings
      internal static var title: String { return L10n.tr("Localizable", "football.settings.title", fallback: "Settings") }
      internal enum Theme {
        /// Dark mode
        internal static var dark: String { return L10n.tr("Localizable", "football.settings.theme.dark", fallback: "Dark mode") }
        /// Tactical board · neon accents
        internal static var darkHint: String { return L10n.tr("Localizable", "football.settings.theme.darkHint", fallback: "Tactical board · neon accents") }
        /// Light mode
        internal static var light: String { return L10n.tr("Localizable", "football.settings.theme.light", fallback: "Light mode") }
        /// Clean pitch · daylight UI
        internal static var lightHint: String { return L10n.tr("Localizable", "football.settings.theme.lightHint", fallback: "Clean pitch · daylight UI") }
      }
    }
    internal enum Share {
      /// Share
      internal static var shareAction: String { return L10n.tr("Localizable", "football.share.shareAction", fallback: "Share") }
      /// Share lineup
      internal static var title: String { return L10n.tr("Localizable", "football.share.title", fallback: "Share lineup") }
      /// 3D view
      internal static var view3D: String { return L10n.tr("Localizable", "football.share.view3D", fallback: "3D view") }
      /// Flat view
      internal static var viewFlat: String { return L10n.tr("Localizable", "football.share.viewFlat", fallback: "Flat view") }
    }
    internal enum Tab {
      /// Lineups
      internal static var lineups: String { return L10n.tr("Localizable", "football.tab.lineups", fallback: "Lineups") }
      /// Scores
      internal static var matches: String { return L10n.tr("Localizable", "football.tab.matches", fallback: "Scores") }
      /// Players
      internal static var players: String { return L10n.tr("Localizable", "football.tab.players", fallback: "Players") }
      /// Settings
      internal static var settings: String { return L10n.tr("Localizable", "football.tab.settings", fallback: "Settings") }
      /// Teams
      internal static var teams: String { return L10n.tr("Localizable", "football.tab.teams", fallback: "Teams") }
    }
    internal enum Tactics {
      /// Draw movement paths on the pitch
      internal static var hint: String { return L10n.tr("Localizable", "football.tactics.hint", fallback: "Draw movement paths on the pitch") }
      /// Tactical mode
      internal static var title: String { return L10n.tr("Localizable", "football.tactics.title", fallback: "Tactical mode") }
      internal enum Tool {
        /// Arrow
        internal static var arrow: String { return L10n.tr("Localizable", "football.tactics.tool.arrow", fallback: "Arrow") }
        /// Clear
        internal static var clear: String { return L10n.tr("Localizable", "football.tactics.tool.clear", fallback: "Clear") }
        /// Zone
        internal static var zone: String { return L10n.tr("Localizable", "football.tactics.tool.zone", fallback: "Zone") }
      }
    }
    internal enum Teams {
      /// New team
      internal static var defaultName: String { return L10n.tr("Localizable", "football.teams.defaultName", fallback: "New team") }
      /// Delete team
      internal static var deleteAction: String { return L10n.tr("Localizable", "football.teams.deleteAction", fallback: "Delete team") }
      /// Delete
      internal static var deleteConfirm: String { return L10n.tr("Localizable", "football.teams.deleteConfirm", fallback: "Delete") }
      /// Delete team?
      internal static var deleteTitle: String { return L10n.tr("Localizable", "football.teams.deleteTitle", fallback: "Delete team?") }
      /// Team squad
      internal static var editorTitle: String { return L10n.tr("Localizable", "football.teams.editorTitle", fallback: "Team squad") }
      /// No saved teams yet. Tap + to create a squad.
      internal static var empty: String { return L10n.tr("Localizable", "football.teams.empty", fallback: "No saved teams yet. Tap + to create a squad.") }
      /// Team name
      internal static var namePlaceholder: String { return L10n.tr("Localizable", "football.teams.namePlaceholder", fallback: "Team name") }
      /// No saved teams yet. Create a squad in My Teams and tap Save team before importing here.
      internal static var pickEmptyForMatch: String { return L10n.tr("Localizable", "football.teams.pickEmptyForMatch", fallback: "No saved teams yet. Create a squad in My Teams and tap Save team before importing here.") }
      /// Pick saved team
      internal static var pickForMatch: String { return L10n.tr("Localizable", "football.teams.pickForMatch", fallback: "Pick saved team") }
      /// Choose formation
      internal static var pickFormation: String { return L10n.tr("Localizable", "football.teams.pickFormation", fallback: "Choose formation") }
      /// Pick a team
      internal static var pickTitle: String { return L10n.tr("Localizable", "football.teams.pickTitle", fallback: "Pick a team") }
      /// %d / %d on pitch
      internal static func rosterCount(_ p1: Int, _ p2: Int) -> String {
        return L10n.tr("Localizable", "football.teams.rosterCount", p1, p2, fallback: "%d / %d on pitch")
      }
      /// Save team
      internal static var save: String { return L10n.tr("Localizable", "football.teams.save", fallback: "Save team") }
      /// Team saved.
      internal static var saved: String { return L10n.tr("Localizable", "football.teams.saved", fallback: "Team saved.") }
      /// Tap a position on the pitch or bench to assign a player.
      internal static var tapSlotHint: String { return L10n.tr("Localizable", "football.teams.tapSlotHint", fallback: "Tap a position on the pitch or bench to assign a player.") }
      /// My Teams
      internal static var title: String { return L10n.tr("Localizable", "football.teams.title", fallback: "My Teams") }
      /// Untitled team
      internal static var unnamed: String { return L10n.tr("Localizable", "football.teams.unnamed", fallback: "Untitled team") }
      /// Enter a team name.
      internal static var validationName: String { return L10n.tr("Localizable", "football.teams.validationName", fallback: "Enter a team name.") }
    }
  }
  internal enum Home {
    internal enum Nav {
      /// Home
      internal static var testEmpty: String { return L10n.tr("Localizable", "home.nav.testEmpty", fallback: "Empty") }
      /// Error
      internal static var testError: String { return L10n.tr("Localizable", "home.nav.testError", fallback: "Error") }
      /// Toast−
      internal static var testToastError: String { return L10n.tr("Localizable", "home.nav.testToastError", fallback: "Toast−") }
      /// Toast+
      internal static var testToastSuccess: String { return L10n.tr("Localizable", "home.nav.testToastSuccess", fallback: "Toast+") }
    }
    internal enum Toast {
      /// This is a demo error toast (SwiftEntryKit).
      internal static var testError: String { return L10n.tr("Localizable", "home.toast.testError", fallback: "This is a demo error toast (SwiftEntryKit).") }
      /// Demo success toast — banks loaded.
      internal static var testSuccess: String { return L10n.tr("Localizable", "home.toast.testSuccess", fallback: "Demo success toast — banks loaded.") }
    }
  }
  internal enum Language {
    /// Language
    internal static var english: String { return L10n.tr("Localizable", "language.english", fallback: "English") }
    /// Japanese
    internal static var japanese: String { return L10n.tr("Localizable", "language.japanese", fallback: "Japanese") }
    /// Vietnamese
    internal static var vietnamese: String { return L10n.tr("Localizable", "language.vietnamese", fallback: "Vietnamese") }
  }
  internal enum Library {
    /// Library
    internal static var title: String { return L10n.tr("Localizable", "library.title", fallback: "Library") }
    internal enum Button {
      /// Shimmer subtitle only
      internal static var shimmerSubtitle: String { return L10n.tr("Localizable", "library.button.shimmerSubtitle", fallback: "Shimmer subtitle only") }
      /// Shimmer title only
      internal static var shimmerTitle: String { return L10n.tr("Localizable", "library.button.shimmerTitle", fallback: "Shimmer title only") }
      /// Test loading (screen)
      internal static var testScreen: String { return L10n.tr("Localizable", "library.button.testScreen", fallback: "Test loading (screen)") }
    }
    internal enum Loaded {
      /// Fake API · %@
      internal static func subtitle(_ p1: Any) -> String {
        return L10n.tr("Localizable", "library.loaded.subtitle", String(describing: p1), fallback: "Fake API · %@")
      }
      /// Library loaded
      internal static var title: String { return L10n.tr("Localizable", "library.loaded.title", fallback: "Library loaded") }
    }
    internal enum Subtitle {
      /// Tap a button to test shimmer
      internal static var hint: String { return L10n.tr("Localizable", "library.subtitle.hint", fallback: "Tap a button to test shimmer") }
    }
  }
  internal enum List {
    internal enum Empty {
      /// Pull down to refresh.
      internal static var message: String { return L10n.tr("Localizable", "list.empty.message", fallback: "Pull down to refresh.") }
      /// List empty / error
      internal static var title: String { return L10n.tr("Localizable", "list.empty.title", fallback: "No items yet") }
    }
    internal enum Error {
      /// Check your connection and try again.
      internal static var message: String { return L10n.tr("Localizable", "list.error.message", fallback: "Check your connection and try again.") }
      /// Couldn't load
      internal static var title: String { return L10n.tr("Localizable", "list.error.title", fallback: "Couldn't load") }
    }
  }
  internal enum Login {
    /// Login
    internal static var title: String { return L10n.tr("Localizable", "login.title", fallback: "Login") }
    internal enum Register {
      /// Register
      internal static var title: String { return L10n.tr("Localizable", "login.register.title", fallback: "Register") }
    }
  }
  internal enum Maintain {
    /// We will be back soon.
    internal static var message: String { return L10n.tr("Localizable", "maintain.message", fallback: "We will be back soon.") }
    /// Maintenance
    internal static var title: String { return L10n.tr("Localizable", "maintain.title", fallback: "Maintenance") }
  }
  internal enum Onboard {
    /// Onboarding
    internal static var start: String { return L10n.tr("Localizable", "onboard.start", fallback: "Get Started") }
  }
  internal enum Scripts {
    internal enum Ads {
      /// Failed: %@
      internal static func failed(_ p1: Any) -> String {
        return L10n.tr("Localizable", "scripts.ads.failed", String(describing: p1), fallback: "Failed: %@")
      }
      /// Hide banner
      internal static var hideBanner: String { return L10n.tr("Localizable", "scripts.ads.hideBanner", fallback: "Hide banner") }
      /// Scripts — Ads demo
      internal static var hint: String { return L10n.tr("Localizable", "scripts.ads.hint", fallback: "Load then show each ad type (AdMob test IDs).") }
      /// Load app open
      internal static var loadAppOpen: String { return L10n.tr("Localizable", "scripts.ads.loadAppOpen", fallback: "Load app open") }
      /// Load banner
      internal static var loadBanner: String { return L10n.tr("Localizable", "scripts.ads.loadBanner", fallback: "Load banner") }
      /// Loading…
      internal static var loading: String { return L10n.tr("Localizable", "scripts.ads.loading", fallback: "Loading…") }
      /// Load interstitial
      internal static var loadInterstitial: String { return L10n.tr("Localizable", "scripts.ads.loadInterstitial", fallback: "Load interstitial") }
      /// Load rewarded
      internal static var loadRewarded: String { return L10n.tr("Localizable", "scripts.ads.loadRewarded", fallback: "Load rewarded") }
      /// Reward: %d %@
      internal static func reward(_ p1: Int, _ p2: Any) -> String {
        return L10n.tr("Localizable", "scripts.ads.reward", p1, String(describing: p2), fallback: "Reward: %d %@")
      }
      /// Show app open
      internal static var showAppOpen: String { return L10n.tr("Localizable", "scripts.ads.showAppOpen", fallback: "Show app open") }
      /// Show banner
      internal static var showBanner: String { return L10n.tr("Localizable", "scripts.ads.showBanner", fallback: "Show banner") }
      /// Show interstitial
      internal static var showInterstitial: String { return L10n.tr("Localizable", "scripts.ads.showInterstitial", fallback: "Show interstitial") }
      /// Show rewarded
      internal static var showRewarded: String { return L10n.tr("Localizable", "scripts.ads.showRewarded", fallback: "Show rewarded") }
      /// Status: %@
      internal static func status(_ p1: Any) -> String {
        return L10n.tr("Localizable", "scripts.ads.status", String(describing: p1), fallback: "Status: %@")
      }
      /// Success: %@
      internal static func success(_ p1: Any) -> String {
        return L10n.tr("Localizable", "scripts.ads.success", String(describing: p1), fallback: "Success: %@")
      }
    }
  }
  internal enum Settings {
    /// Appearance
    internal static var appearance: String { return L10n.tr("Localizable", "settings.appearance", fallback: "Appearance") }
    /// App Version
    internal static var appVersion: String { return L10n.tr("Localizable", "settings.appVersion", fallback: "App Version") }
    /// Backup & Sync
    internal static var backup: String { return L10n.tr("Localizable", "settings.backup", fallback: "Backup & Sync") }
    /// Help & Support
    internal static var help: String { return L10n.tr("Localizable", "settings.help", fallback: "Help & Support") }
    /// Language
    internal static var language: String { return L10n.tr("Localizable", "settings.language", fallback: "Language") }
    /// Notifications
    internal static var notifications: String { return L10n.tr("Localizable", "settings.notifications", fallback: "Notifications") }
    /// Privacy
    internal static var privacy: String { return L10n.tr("Localizable", "settings.privacy", fallback: "Privacy") }
    /// Rate Us
    internal static var rateUs: String { return L10n.tr("Localizable", "settings.rateUs", fallback: "Rate Us") }
    /// Security
    internal static var security: String { return L10n.tr("Localizable", "settings.security", fallback: "Security") }
    /// Storage
    internal static var storage: String { return L10n.tr("Localizable", "settings.storage", fallback: "Storage") }
    /// Terms of Service
    internal static var terms: String { return L10n.tr("Localizable", "settings.terms", fallback: "Terms of Service") }
    /// Theme
    internal static var theme: String { return L10n.tr("Localizable", "settings.theme", fallback: "Theme") }
    /// Settings
    internal static var title: String { return L10n.tr("Localizable", "settings.title", fallback: "Settings") }
    internal enum AppVersion {
      /// 1.2.3 (123)
      internal static var value: String { return L10n.tr("Localizable", "settings.appVersion.value", fallback: "1.2.3 (123)") }
    }
    internal enum Section {
      /// ABOUT
      internal static var about: String { return L10n.tr("Localizable", "settings.section.about", fallback: "ABOUT") }
      /// GENERAL
      internal static var general: String { return L10n.tr("Localizable", "settings.section.general", fallback: "GENERAL") }
      /// PREFERENCES
      internal static var preferences: String { return L10n.tr("Localizable", "settings.section.preferences", fallback: "PREFERENCES") }
    }
    internal enum Theme {
      /// Dark
      internal static var dark: String { return L10n.tr("Localizable", "settings.theme.dark", fallback: "Dark") }
      /// Light
      internal static var light: String { return L10n.tr("Localizable", "settings.theme.light", fallback: "Light") }
      /// System
      internal static var system: String { return L10n.tr("Localizable", "settings.theme.system", fallback: "System") }
    }
  }
  internal enum Tab {
    /// Tab bar
    internal static var home: String { return L10n.tr("Localizable", "tab.home", fallback: "Home") }
    /// Library
    internal static var library: String { return L10n.tr("Localizable", "tab.library", fallback: "Library") }
    /// Record
    internal static var record: String { return L10n.tr("Localizable", "tab.record", fallback: "Record") }
    /// Scripts
    internal static var scripts: String { return L10n.tr("Localizable", "tab.scripts", fallback: "Scripts") }
    /// Settings
    internal static var settings: String { return L10n.tr("Localizable", "tab.settings", fallback: "Settings") }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = TranslationService.shared.lookupTranslation(key, table, value)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

