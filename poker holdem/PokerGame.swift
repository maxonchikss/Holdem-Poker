import Foundation

//Точка входа бота в игру
//                let botEnters = bot.shouldEnter(withHand: opHand)
//                    if !botEnters {
//                        heroStack += bank
//                        print("Bot fold")
//                        return false
//                    }else{
//                        opStack -= 10
//                        bank += 10
//                        return true
//                    }

class PokerGame{
    let bot = PokerOponent(position: .BigBlind)
    let smallBlindBet = 5
    let bigBlindBet = 10
    var heroStack: Int
    var opStack: Int
    var heroPosition = Position.SmallBlind
    var opPosition = Position.BigBlind
    var bank: Int = 0
    var deck: [Card] = []
    var heroHand: [Card] = []
    var opHand: [Card] = []
    var board: [Card] = []
    
    init(BigBlindes: Int){
        self.opStack = BigBlindes
        self.heroStack = BigBlindes
    }
    
    func showBettingRoundInfo() -> Void{
        print("The board is: \(board)")
        print("Your hand: \(heroHand)", "Your stack now: \(Double(heroStack)/Double(bigBlindBet))BB", "Your op stack now: \(Double(opStack)/Double(bigBlindBet))BB", "Bank now \(Double(bank)/Double(bigBlindBet))BB")
    }
    
    func showPreflopInfo() -> Void{
        print("Your oponent required bet \(Double(bigBlindBet)/Double(bigBlindBet)) BB, your required bet is \(Double(smallBlindBet)/Double(bigBlindBet)) BB")
        print("You turn: 1. Call 2. Raise 3. Fold ")
    }
    
    //Создание рук
    func newPokerHand(){
        deck = DeckCreator()
        heroHand = [deck[0], deck[2]]
        opHand = [deck[1], deck[3]]
        board = []
        bank = 0
    }
    
    //Смена позиции
    func rotatepositions(){
        if heroPosition == Position.BigBlind{
            heroPosition = Position.SmallBlind
            opPosition = Position.BigBlind
        }else{
            heroPosition = Position.BigBlind
            opPosition = Position.SmallBlind
        }
    }
    
    //Раздача карт
    func dealCards(){
        print("You have \(heroHand),", "your position is \(heroPosition)", "your oponent position is \(opPosition)")
        print("Your stack now: \(String(format: "%.1f", Double(heroStack) * 0.1)) BB,", "your op stack now: \(String(format: "%.1f", Double(opStack) * 0.1)) BB")
        
    }
    //Игра на всё
    func allInSituation() -> Bool{
        print("All-in")
        if board.count < 3 {
            board = Array(deck[4...6])
            print("\(board)")
            sleep(2)
        }

        if board.count < 4 {
            board.append(deck[7])
            print("\(board)")
            sleep(2)
        }

        if board.count < 5 {
            board.append(deck[8])
            print("\(board)")
            sleep(1)
        }
        
        showdown()
        return false
    }

    func placeBet(playerStack: inout Int, amount: Int){
        let bet = min(amount, playerStack)
        playerStack -= bet
    }
    
    func addToStack(playerStack: inout Int, amount: Int){
        playerStack += amount
    }
    
    func addToBank(amount: Int){
        bank += amount
    }
    func checkAllInSB() -> Bool{
        if heroStack <= smallBlindBet{
            addToBank(amount: heroStack*2)
            placeBet(playerStack: &heroStack, amount: heroStack)
            placeBet(playerStack: &opStack, amount: heroStack)
            return allInSituation()
        }
        return true
    }
    func checkAllInBB() -> Bool{
        if heroStack <= bigBlindBet{
            addToBank(amount: heroStack*2)
            placeBet(playerStack: &heroStack, amount: heroStack)
            placeBet(playerStack: &opStack, amount: heroStack)
            return allInSituation()
        }
        return true
    }
    
    
    
    //Префлоп
    func preflopAction() -> Bool{
        if heroPosition == Position.SmallBlind{
            
            if !checkAllInSB() {return false}
            showPreflopInfo()
            
            
            guard let choice = Int(readLine() ?? ""), choice >= 1 && choice <= 3 else{
                print("Wrong input -> Fold")
                placeBet(playerStack: &heroStack, amount: smallBlindBet)
                addToStack(playerStack: &opStack, amount: smallBlindBet)
                if heroStack == 0 || opStack == 0 { return allInSituation() }
                return false }
            
            switch choice {
            case 1:
                addToBank(amount: (min(bigBlindBet, heroStack) + min(bigBlindBet, opStack)))
                placeBet(playerStack: &heroStack, amount: bigBlindBet)
                placeBet(playerStack: &opStack, amount: bigBlindBet)
                
                if heroStack == 0 || opStack == 0 { return allInSituation() }
                return true

            case 2:
                if heroStack <= 20{
                    let localBet = heroStack
                    addToBank(amount: min(localBet, heroStack))
                    placeBet(playerStack: &heroStack, amount: localBet)
                    addToBank(amount: min(localBet, opStack))
                    placeBet(playerStack: &opStack, amount: localBet)
                    return allInSituation()
                }else{
                    print("Enter how much BB you wanna bet:")
                    guard let safeRaizeChoize = Double(readLine() ?? ""), (safeRaizeChoize*10 <= Double(heroStack) && safeRaizeChoize >= 2.0) else{
                        print("wrong input -> Fold")
                        placeBet(playerStack: &heroStack, amount: smallBlindBet)
                        addToStack(playerStack: &opStack, amount: smallBlindBet)
                        if heroStack == 0 || opStack == 0 { return allInSituation() }
                        return false
                    }

                    let raizeChoize = Int(safeRaizeChoize * 10)
                    addToBank(amount: min(raizeChoize, heroStack))
                    placeBet(playerStack: &heroStack, amount: raizeChoize)
                    addToBank(amount: min(raizeChoize, opStack))
                    placeBet(playerStack: &opStack, amount: raizeChoize)
                    if heroStack == 0 || opStack == 0 { return allInSituation() }
                    return true
                }
            case 3:
                placeBet(playerStack: &heroStack, amount: smallBlindBet)
                addToStack(playerStack: &opStack, amount: smallBlindBet)
                if heroStack == 0 || opStack == 0 { return allInSituation() }
                return false
            default:
                return false
            }
        }
        else{
            
            if !checkAllInBB() {return false}
            showPreflopInfo()
            
            guard let choice = Int(readLine() ?? ""), choice >= 1 && choice <= 3 else{
                print("Wrong input -> Fold")
                placeBet(playerStack: &heroStack, amount: bigBlindBet)
                addToStack(playerStack: &opStack, amount: bigBlindBet)
                if heroStack == 0 || opStack == 0 { return allInSituation() }
                return false
            }
            
            switch choice {
            case 1:
                addToBank(amount: bigBlindBet)
                placeBet(playerStack: &heroStack, amount: bigBlindBet)
                addToBank(amount: bigBlindBet)
                placeBet(playerStack: &opStack, amount: bigBlindBet)
                if heroStack == 0 || opStack == 0 { return allInSituation() }
                return true
            case 2:
                if heroStack <= 20{
                    let localBet = heroStack
                    addToBank(amount: min(localBet, heroStack))
                    placeBet(playerStack: &heroStack, amount: localBet)
                    addToBank(amount: min(localBet, opStack))
                    placeBet(playerStack: &opStack, amount: localBet)
                    return allInSituation()

                }else{
                    print("Enter how much BB you wanna bet:")
                    guard let safeRaizeChoize = Double(readLine() ?? ""), (safeRaizeChoize*10 <= Double(heroStack) && safeRaizeChoize >= 2.0) else{
                        print("wrong input -> Fold")
                        placeBet(playerStack: &heroStack, amount: bigBlindBet)
                        addToStack(playerStack: &opStack, amount: bigBlindBet)
                        return false
                    }

                    let raizeChoize = Int(safeRaizeChoize * 10)
                    addToBank(amount: min(raizeChoize, heroStack))
                    placeBet(playerStack: &heroStack, amount: raizeChoize)
                    addToBank(amount: min(raizeChoize, opStack))
                    placeBet(playerStack: &opStack, amount: raizeChoize)
                    if heroStack == 0 || opStack == 0 { return allInSituation() }
                    return true
                }
                
            case 3:
                placeBet(playerStack: &heroStack, amount: bigBlindBet)
                addToStack(playerStack: &opStack, amount: bigBlindBet)
                if heroStack == 0 || opStack == 0 { return allInSituation() }
                return false
                
            default:
                return false
            }
        }
    }

    
    // Круг ставок
    func bettingRound(stage: String, newCards: [Card]) -> Bool{
        board.append(contentsOf: newCards)
        showBettingRoundInfo()
        
        if heroPosition == Position.SmallBlind{
            let opBet = min(Int.random(in: 10...bank), opStack)
            print("Your op bet \(Double(opBet)/10)BB", "You turn: 1. Call 2. Raise 3. Fold")
            
            guard let choice = Int(readLine() ?? ""), choice >= 1 && choice <= 3 else{
                print("Wrong input -> Fold")
                addToStack(playerStack: &opStack, amount: bank)
                return false
            }
            
            switch choice {
            case 1:
                addToBank(amount: opBet)
                placeBet(playerStack: &opStack, amount: opBet)
                addToBank(amount: opBet)
                placeBet(playerStack: &heroStack, amount: opBet)
                if heroStack == 0 || opStack == 0 { return allInSituation() }
                return true
            case 2:
                if heroStack <= 20{
                    let localBet = heroStack
                    addToBank(amount: min(localBet, heroStack))
                    placeBet(playerStack: &heroStack, amount: localBet)
                    addToBank(amount: min(localBet, opStack))
                    placeBet(playerStack: &opStack, amount: localBet)
                    return allInSituation()
                }else{
                    print("Enter how much BB you wanna bet:")
                    guard let safeRaizeChoize = Double(readLine() ?? ""), (safeRaizeChoize*10 <= Double(heroStack) && safeRaizeChoize >= 2.0) else{
                        print("wrong input -> Fold")
                        addToStack(playerStack: &opStack, amount: bank)
                        if heroStack == 0 || opStack == 0 { return allInSituation() }
                        return false
                    }

                    let raizeChoize = Int(safeRaizeChoize * 10)
                    addToBank(amount: min(raizeChoize, heroStack))
                    placeBet(playerStack: &heroStack, amount: raizeChoize)
                    addToBank(amount: min(raizeChoize, opStack))
                    placeBet(playerStack: &opStack, amount: raizeChoize)
                    if heroStack == 0 || opStack == 0 { return allInSituation() }
                    return true
                }
            case 3:
                addToStack(playerStack: &opStack, amount: bank)
                return false
            default:
                return false
            }
        }else{
            
        print("You turn: 1. Check 2. Bet 3. Fold")
            
        guard let choice = Int(readLine() ?? ""), choice >= 1 && choice <= 3 else{
            print("Wrong input -> Fold")
            addToStack(playerStack: &opStack, amount: bank)
            return false
        }
        
        switch choice {
        case 1:
            print("You both checked")
            return true
        case 2:
            if heroStack <= 10{
                let localBet = heroStack
                addToBank(amount: min(localBet, heroStack))
                placeBet(playerStack: &heroStack, amount: localBet)
                addToBank(amount: min(localBet, opStack))
                placeBet(playerStack: &opStack, amount: localBet)
                return allInSituation()
            }else{
                print("Enter how much BB you wanna bet:")
                guard let safeRaizeChoize = Double(readLine() ?? ""), (safeRaizeChoize*10 <= Double(heroStack)) else{
                    print("wrong input -> Fold")
                    addToStack(playerStack: &opStack, amount: bank)
                    if heroStack == 0 || opStack == 0 { return allInSituation() }
                    return false
                }

                let raizeChoize = Int(safeRaizeChoize * 10)
                addToBank(amount: min(raizeChoize, heroStack))
                placeBet(playerStack: &heroStack, amount: raizeChoize)
                addToBank(amount: min(raizeChoize, opStack))
                placeBet(playerStack: &opStack, amount: raizeChoize)
                if heroStack == 0 || opStack == 0 { return allInSituation() }
                return true
            }
        case 3:
            addToStack(playerStack: &opStack, amount: bank)
            return false
        default:
            return false
        }
    }
    }
    
    func flop() -> Bool{
        bettingRound(stage: "FLOP", newCards: [deck[4], deck[5], deck[6]])
        
    }
    
    func turn() -> Bool{
        bettingRound(stage: "TURN", newCards: [deck[7]])
        
    }
    
    func river() -> Bool{
        bettingRound(stage: "RIVER", newCards: [deck[8]])
    }
    
    func showdown(){
        let heroCombination = heroHand + board
        let opCombination = opHand + board
        let heroBestCombination = Combinations(cards: heroCombination)
        let opBestCombination = Combinations(cards: opCombination)
        
        if heroBestCombination.isStronger(than: opBestCombination) {
            print("You win")
            print("Oponent have \(opHand), Bank was \(String(format: "%.1f", Double(bank) * 0.1))BB")
            addToStack(playerStack: &heroStack, amount: bank)
        } else if opBestCombination.isStronger(than: heroBestCombination) {
            print("You lose")
            print("Oponent have \(opHand), Bank was \(String(format: "%.1f", Double(bank) * 0.1))BB")
            addToStack(playerStack: &opStack, amount: bank)
        } else {
            print("Split")
            print("Oponent have \(opHand), Bank was \(String(format: "%.1f", Double(bank) * 0.1))BB")
            addToStack(playerStack: &heroStack, amount: bank/2)
            addToStack(playerStack: &opStack, amount: bank/2)
        }
        if heroStack == 0 || opStack == 0{
            print("Game over")
        }
    }
    
    
    
    func startGame() {
        while heroStack > 0 && opStack > 0 {
            newPokerHand()
            dealCards()
            
            if !preflopAction() { rotatepositions(); continue }
            if !flop() { rotatepositions(); continue }
            if !turn() { rotatepositions(); continue }
            if !river() { rotatepositions(); continue }
            showdown()
            rotatepositions()
            
        }
    }
}
