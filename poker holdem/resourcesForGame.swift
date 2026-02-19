import Foundation
enum Suit: String, CaseIterable{
    case hearts = "♥", diamonds = "♦", clubs = "♣", spades = "♠"
}

enum Rank: Int, CaseIterable{
    case two = 2, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace
}

enum Position: Int{
    case SmallBlind = 0, BigBlind = 1
}

struct Card{
    var rank:Rank
    var suit:Suit
}

struct PokerHand{
    let cards: [Card]
    init(cards: [Card]){
        self.cards = cards
    }
}

//определение комбинаций
class PokerCombinations{
    let cards: [Card]
    
    init(cards: [Card]){
        self.cards = cards
    }
    
    func handType() -> HandType{
        let ranks = cards.map { $0.rank.rawValue }.sorted()
        let suits = cards.map { $0.suit }
        let isRoyalRanks = ranks == [10, 11, 12, 13, 14]
        let isSameSuit = Set(suits).count == 1
        let straight = {ranks[0]+1 == ranks[1] && ranks[1]+1 == ranks[2]  && ranks[2]+1 == ranks[3]  && ranks[3]+1 == ranks[4] ? true : false}()
        var ranksCount: [Int : Int] = [:]
        for rank in ranks{
            ranksCount[rank, default: 0] += 1
        }
        let frequency = Array(ranksCount.values).sorted()
    
        if isRoyalRanks && isSameSuit { return .royalFlush }
        if isSameSuit && straight{ return .straightFlush }
        if ranks == [2, 3, 4, 5, 14] && isSameSuit{ return .straightFlush }
        if frequency == [1, 4] { return .fourOfAKind }
        if frequency == [2, 3]{ return .fullHouse }
        if isSameSuit{ return .flush }
        if straight{ return .straight }
        if ranks == [2, 3, 4, 5, 14]{ return .straight }
        if frequency == [1, 1, 3]{ return .threeOfAKind }
        if frequency == [1, 2, 2]{ return .twoPair }
        if frequency == [1, 1, 1, 2]{ return .pair }
        return .highCard
    }
    
    func isStronger(than other: PokerCombinations) -> Bool {
        let selfType = self.handType()
        let otherType = other.handType()
        
        if selfType != otherType {
            return selfType > otherType
        }
        
        return compareSameType(other)
    }
    
    private func compareSameType(_ other: PokerCombinations) -> Bool {
        let selfRanks = cards.map { $0.rank.rawValue }.sorted(by: >)
        let otherRanks = other.cards.map { $0.rank.rawValue }.sorted(by: >)
        
        for i in 0..<selfRanks.count {
            if selfRanks[i] != otherRanks[i] {
                return selfRanks[i] > otherRanks[i]
            }
        }
        return false
    }
    
    enum HandType:Int{
        case highCard
        case pair
        case twoPair
        case threeOfAKind
        case straight
        case flush
        case fullHouse
        case fourOfAKind
        case straightFlush
        case royalFlush

    }
}
//создание колоды
func DeckCreator() -> [Card]{
    var deck: [Card] = []
    for suit in Suit.allCases{
        for rank in Rank.allCases{
            deck.append(Card(rank: rank, suit: suit))
        }
    }
    deck.shuffle()
    return deck
}
//сильнейшая комбинация из 7 кард
func Combinations(cards: [Card]) -> PokerCombinations{
    if cards.count == 5{
        return PokerCombinations(cards: cards)
    }
    if cards.count == 6{
        var allHands: [PokerCombinations] = []
        for i in 0..<cards.count {
            var fiveCards = cards
            fiveCards.remove(at: i)
            allHands.append(PokerCombinations(cards: fiveCards))
        }
        
        var bestHand = allHands[0]
        for currentHand in allHands {
            if currentHand.isStronger(than: bestHand) {
                bestHand = currentHand
            }
        }
        return bestHand
    }
    if cards.count == 7{
        let hand = Array(cards.prefix(2))
        let board = Array(cards.suffix(5))
        var allHands: [PokerCombinations] = []
        
        //2 свои + 3 с борда
        for i in 0..<board.count{
            for j in (i+1)..<board.count{
                for k in (j+1)..<board.count{
                    let newHand = [hand[0], hand[1], board[i], board[j], board[k]]
                    allHands.append(PokerCombinations(cards: newHand))
                }
            }
        }
        //1 своя и 4 с борда
        for i in hand{
            for j in 0..<board.count{
                var fourBoard = board
                fourBoard.remove(at: j)
                let fiveCardHand = [i] + fourBoard
                allHands.append(PokerCombinations(cards: fiveCardHand))
            }
        }
        //все 5 с борда
        allHands.append(PokerCombinations(cards: board))
        
        var bestHand = allHands[0]
        for currentHand in allHands{
            if currentHand .isStronger(than: bestHand){
                bestHand = currentHand
            }
        }
        return bestHand
    }
    return PokerCombinations(cards: Array(cards.prefix(5)))
}

extension PokerCombinations.HandType: Comparable {
    static func < (lhs: PokerCombinations.HandType, rhs: PokerCombinations.HandType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static func == (lhs: PokerCombinations.HandType, rhs: PokerCombinations.HandType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
extension Card: CustomStringConvertible {
    var description: String {
        let rankSymbol: String
        switch rank {
        case .jack: rankSymbol = "J"
        case .queen: rankSymbol = "Q"
        case .king: rankSymbol = "K"
        case .ace: rankSymbol = "A"
        default: rankSymbol = String(rank.rawValue)
        }
        return rankSymbol + suit.rawValue
    }
}

//    func OnlyGoodRandomCombination() -> Void{
//    var deck = DeckCreator()
//    deck.shuffle()
//    deck = Array(deck.prefix(5))
//    if PokerCombinations(cards: deck).handType() != PokerCombinations.HandType.highCard && PokerCombinations(cards: deck).handType() != PokerCombinations.HandType.pair &&  PokerCombinations(cards: deck).handType() != PokerCombinations.HandType.twoPair && PokerCombinations(cards: deck).handType() != PokerCombinations.HandType.threeOfAKind && PokerCombinations(cards: deck).handType() != PokerCombinations.HandType.straight && PokerCombinations(cards: deck).handType() != PokerCombinations.HandType.flush && PokerCombinations(cards: deck).handType() != PokerCombinations.HandType.fullHouse && PokerCombinations(cards: deck).handType() != PokerCombinations.HandType.fourOfAKind{
//        print(deck)
//        print(PokerCombinations(cards: deck).handType())
//    }
//}

