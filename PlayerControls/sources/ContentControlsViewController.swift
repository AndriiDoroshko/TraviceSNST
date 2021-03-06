//  Copyright © 2016 One by Aol : Publishers. All rights reserved.

import Foundation

///Generate prism for confirmed enum 
public protocol Prism {}

/// Base class for implementing custom content
/// video controls.
open class ContentControlsViewController: UIViewController {
    public weak var settingsViewController: SettingsViewController?
    public var props: Props = .noPlayer {
        didSet {
            guard isViewLoaded else { return }
            settingsViewController?.props = ContentControlsViewController.settingProps(from: props)
            view.setNeedsLayout()
        }
    }
    
    public enum Props: Prism {
        case noPlayer

        case player(Player)
        
        case pictureInPicture
        
        public struct Player {
            public var playlist: Playlist?
            public struct Playlist {
                public var next: Action<Void>?
                public var prev: Action<Void>?
                public init() { }
            }

            public var item = Item.nonplayable("")
            public enum Item: Prism {
                case playable(Controls)
                case nonplayable(String)
            }
            
            public init() { }
        }
    }
}

extension ContentControlsViewController.Props.Player.Item {
    public struct Controls {
        public var title = ""
        public var loading = false
        
        public var playbackAction: Playback = .none
        public enum Playback: Prism {
            case none
            case play(Action<Void>)
            case pause(Action<Void>)
            case replay(Action<Void>)
        }
        
        public var live = Live()
        public struct Live {
            public var isHidden = true
            public var dotColor: UIColor?
            public init() { }
        }
        public var seekbar: Seekbar?
        public struct Seekbar {
            public typealias Seconds = UInt
            public typealias Progress = Double
            
            public var duration: Seconds = 0
            public var currentTime: Seconds = 0
            public var progress: Progress = 0.0
            public var buffered: Progress = 0.0
            
            public var seeker = Seeker()
            
            public struct Seeker {
                public var seekTo: Action<Seconds>?
                
                public var state = State()
                public struct State {
                    public var start: Action<Progress> = nop
                    public var update: Action<Progress> = nop
                    public var stop: Action<Progress> = nop
                    public init() { }
                }
                public init() { }
            }
            public init() { }
        }
        
        /// This field will be available only when 360 video is active
        public var camera: Camera?
        public struct Camera {
            /// Angles of current camera position - measured in radians.
            public struct Angles {
                
                /// zero - center, positive - right part, negative - left part.
                public var horizontal: Float = 0.0
                
                /// zero - horizon, positive - above horizon, negative - below
                public var vertical: Float = 0.0
                public init() { }
            }
            
            public var angles = Angles()
            public var moveTo: Action<Angles> = nop
            public init() { }
        }
        
        /// URL or UIImage for the thumbnail.
        public var thumbnail: Thumbnail?
        public enum Thumbnail: Prism {
            case url(URL) //swiftlint:disable:this type_name
            case image(UIImage)
        }
        
        public var sideBarViewHidden = true
        
        public var error: Error?
        public struct Error {
            public var message = ""
            public var retryAction: Action<Void>?
            public init() { }
        }
        
        public var pictureInPictureControl: PictureInPictureControl = .unsupported
        public enum PictureInPictureControl: Prism {
            case unsupported
            case impossible
            case possible(Action<Void>)
        }
        
        public enum Subtitles: Prism {
            case `internal`(MediaGroupControl?)
            case external(external: External, control: MediaGroupControl)
            
            public enum External: Prism {
                case none
                case unavailable
                case available(state: State)
                public enum State: Prism {
                    case active(text: String?), loading, inactive, error
                }
            }
        }
        
        public struct MediaGroupControl {
            public var options: [Option] = []
            public struct Option {
                public var name = ""
                public var selected = false
                public var select: Action<Void> = nop
                public init() { }
            }
            
            public init() { }
        }
        
        public var legible: Subtitles = .`internal`(nil)
        public var audible: MediaGroupControl?
        
        public enum Settings: Prism {
            case hidden
            case disabled
            case enabled(Action<Void>)
        }
        public var settings: Settings = .disabled
        
        public enum AirPlay: Prism {
            case hidden
            case enabled
            case active
        }
        public var airplay: AirPlay = .hidden
        
        public init() { }
    }
}
