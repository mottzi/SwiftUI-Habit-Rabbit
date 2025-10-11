import SwiftUI

extension Habit.Dashboard.Sheet {
    
    var iconSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Icon")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            iconPickerButton
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var iconPickerButton: some View {
        Button {
            showIconPicker = true
        } label: {
            HStack(alignment: .lastTextBaseline) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(colorScheme == .light ? .black : .white)
                    .padding(.leading, 1)
                
                Text("Change")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
    
    var iconPickerSheet: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Self.commonIcons, id: \.self) { icon in
                        Button {
                            Task {
                                self.icon = icon
                                try? await Task.sleep(for: .milliseconds(100))
                                showIconPicker = false
                                focusedField = nil
                            }
                        } label: {
                            Image(systemName: icon)
                                .font(.title3)
                                .frame(width: 44, height: 44)
                                .padding(4)
                                .background {
                                    switch self.icon == icon {
                                        case true:  Circle().fill(.blue)
                                        case false: Habit.Card.Background(in: .circle).showShadows(false)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 16)
            }
            .toolbar { closeButton }
        }
        .presentationDetents([.large])
        .presentationBackground {
            Rectangle()
                .fill(.thickMaterial)
                .padding(.bottom, -100)
        }
    }
    
    private var closeButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel) {
                showIconPicker = false
                focusedField = nil
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .tint(.red)
        }
    }
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: 6)
    }
    
    static let commonIcons: [String] = [
        // communitction
        "microphone.fill",
        "message.fill",
        "quote.closing",
        "phone.fill",
        "video.fill",
        "envelope.front.fill",
        "envelope.fill",
        "waveform",
        "recordingtape",
        "shippingbox.fill",
        "clock.fill",
        "alarm.fill",
        "hourglass",
        
        
        // eat & drink
        "cup.and.saucer.fill",
        "mug.fill",
        "takeoutbag.and.cup.and.straw.fill",
        "wineglass.fill",
        "waterbottle.fill",
        "birthday.cake.fill",
        "carrot.fill",
        "fork.knife",
        "scalemass.fill",
        
        // personal
        "shower.fill",
        "bathtub.fill",
        "comb.fill",
        "sunglasses",
        
        "frying.pan.fill",
        "bed.double.fill",
        "washer.fill",
        "dryer.fill",
        "dishwasher.fill",
        "oven.fill",
        "stove.fill",
        "refrigerator.fill",
        "toilet.fill",
        "teddybear.fill",
        "gift.fill",
        
        
        // leasure
        "videoprojector.fill",
        "party.popper.fill",
        "balloon.2.fill",
        "laser.burst",
        "popcorn.fill",
        "stroller.fill",
        "movieclapper",
        "ticket.fill",
        "film.stack.fill",
        "gamecontroller.fill",
        "paintpalette.fill",
        
        // nature
        "tree.fill",
        "fossil.shell.fill",
        
        
        // games
        "puzzlepiece.extension.fill",
        "theatermasks.fill",
        "theatermask.and.paintbrush.fill",
        
        // weather
        "sun.max.fill",
        "sunrise.fill",
        "sunset.fill",
        "sun.horizon.fill",
        "sun.rain.fill",
        "moon.fill",
        "moon.stars.fill",
        "cloud",
        "smoke.fill",
        "cloud.rain.fill",
        "cloud.bolt.fill",
        "cloud.sun.fill",
        "wind",
        "snowflake",
        "tornado",
        "thermometer.high",
        "degreesign.fahrenheit",
        "degreesign.celsius",
        "rainbow",
        
        // maps
        "figure.walk",
        "figure.wave",
        "cart.fill",
        "basket.fill",
        "creditcard.fill",
        "wallet.bifold.fill",
        "wand.and.sparkles.inverse",
        
        "location.fill",
        "mappin",
        "map.fill",
        "car.fill",
        "bus.fill",
        "tram.fill",
        "bicycle",
        "fuelpump.fill",
        "licenseplate.fill",
        "point.bottomleft.forward.to.point.topright.scurvepath.fill",
        "binoculars.fill",
        "tent.fill",
        "signpost.right.fill",
        "fuelpump.fill",
        
        // office
        "door.left.hand.open",
        "door.left.hand.closed",
        "door.sliding.right.hand.open",
        "door.sliding.right.hand.closed",
        "door.garage.open",
        "door.garage.closed",
        "air.purifier.fill",
        "heater.vertical.fill",
        "spigot.fill",
        
        "pencil.and.scribble",
        "rectangle.and.pencil.and.ellipsis",
        "highlighter",
        "square.and.pencil",
        "eraser.fill",
        "paperplane.fill",
        "tray.full.fill",
        "tray.2.fill",
        "archivebox.fill",
        "externaldrive.fill",
        "document.fill",
        "document.on.document.fill",
        "list.bullet.clipboard.fill",
        "pencil.and.list.clipboard",
        "note.text",
        "calendar",
        "book.fill",
        "text.book.closed.fill",
        "magazine.fill",
        "newspaper.fill",
        "books.vertical.fill",
        "menucard.fill",
        "bookmark.fill",
        "paperclip",
        "link",
        "gauge.with.dots.needle.bottom.0percent",
        "dice.fill",
        "printer.fill",
        "scanner.fill",
        "headset",
        "radio.fill",
        "battery.100percent",
        "battery.100percent.bolt",
        
        // wear
        "graduationcap.fill",
        "backpack.fill",
        "bag.fill",
        "handbag.fill",
        "briefcase.fill",
        "suitcase.fill",
        "suitcase.cart.fill",
        "suitcase.rolling.fill",
        
        // tools
        "ruler.fill",
        "flashlight.on.fill",
        "camera.fill",
        "web.camera.fill",
        "gear",
        "scissors",
        "paintbrush.fill",
        "paintbrush.pointed.fill",
        "level.fill",
        "wrench.adjustable.fill",
        "hammer.fill",
        "screwdriver.fill",
        "eyedropper.halffull",
        "lightbulb.fill",
        "fan.fill",
        "poweroutlet.strip.fill",
        "powerplug.fill",
        "lock.fill",
        "lock.open.fill",
        "key.fill",
        "pin.fill",
        
        // sport
        "dumbbell.fill",
        "soccerball.inverse",
        "baseball.fill",
        "basketball.fill",
        "american.football.fill",
        "tennis.racket",
        "tennisball.fill",
        "volleyball.fill",
        "skateboard",
        "skis.fill",
        "snowboard.fill",
        "surfboard.fill",
        "rosette",
        "medal.fill",
        "medal.star.fill",
        "shield.fill",
        "trophy.fill",
        "sailboat.fill",
        "helmet.fill",
        "hat.cap.fill",
        "tshirt.fill",
        "jacket.fill",
        "coat.fill",
        "shoe.fill",
        "hat.widebrim.fill",
        "crown.fill",
        
        // music
        "pianokeys.inverse",
        "guitars.fill",
        
        // medical
        "inhaler.fill",
        "cross.case.fill",
        "syringe.fill",
        "pill.fill",
        "cross.vial.fill",
        
        // other
        "tag.fill",
        "lasso",
        "trash",
        "folder.fill",
        "megaphone.fill",
        "speaker.wave.2.fill",
        "bell.fill",
        "music.microphone",
        "magnifyingglass",
        "flag.fill",
        "flag.pattern.checkered",
        "flag.2.crossed.fill",
    ]
    
}
