// Реализация логики покерного противника находящегося в позициях BigBlind/SmallBlind с диапазонным мышлением и элементом рандома в принимаемых решениях
import Foundation

class PokerOponent{
    let position:  Position
    init(position: Position) {
        self.position = position
    }
    func handStrength(hand: [Card], board: [Card]) -> PokerCombinations.HandType {
        let best = Combinations(cards: hand + board)
        return best.handType()
    }
    func hasMadeHand(hand: [Card], board: [Card]) -> Bool {
        let strength = handStrength(hand: hand, board: board)
        return strength >= .pair
    }
//для рандома
    func rollDice(outOf total: Int, success: Int) -> Bool {
        let roll = Int.random(in: 1...total)
        return roll <= success
    }
    
    func shouldEnter(withHand: [Card]) -> Bool{

        let card1 = withHand[0]
        let card2 = withHand[1]
        let ranks = [card1.rank.rawValue, card2.rank.rawValue].sorted(by: >)

        
        let isSuited = card1.suit == card2.suit
        let isPair = ranks[0] == ranks[1]
        let hasAce = ranks[0] == Rank.ace.rawValue && (ranks[0] == Rank.five.rawValue || ranks[1] >= Rank.eight.rawValue)
        let isHigh = ranks[0] >= Rank.ten.rawValue
        
        let goodHand1 = ranks[0] == Rank.jack.rawValue && ranks[1] == Rank.nine.rawValue
        let goodHand2 = ranks[0] == Rank.ten.rawValue && ranks[1] == Rank.eight.rawValue
        let goodHand3 = ranks[0] == Rank.seven.rawValue && ranks[1] == Rank.six.rawValue
        let goodHand4 = ranks[0] == Rank.five.rawValue && ranks[1] == Rank.four.rawValue
        
        let baseDecision = isPair || hasAce || (isSuited && (isHigh || goodHand1 || goodHand2 || goodHand3 || goodHand4))
        
        if !baseDecision && Double.random(in: 0.1...1) < 0.05{
            return true
        }
        return baseDecision
    }
    
//    func decideActionFlop(board: [Card], hand: [Card], wasAggressor: Bool,opponentBet: Int = 0) -> BotAction {
//        let madeHand = hasMadeHand(hand: hand, board: board)
//        let strength = handStrength(hand: hand, board: board)
//        
//        if wasAggressor {
//            // бот рейзил играем прямолинейно
//            if rollDice(outOf: 10, success: 8) {
//                let betSize = max(bankSize(board: board, hand: hand) * 6 / 10, 5)
//                return .raise(betSize)
//            }// бот рейзил играем хитро
//            else if rollDice(outOf: 2, success: 1) {
//                if strength >= .straight {
//                    return .check
//                } else {
//                    return .check
//                }
//            }
//        } else {
//            if opponentBet > 0 {
//                // Герой поставил на флопе
//                if rollDice(outOf: 10, success: 2) && madeHand {
//                    // 2/10 — рейз с совпадением
//                    return .raise(opponentBet * 2)
//                } else if rollDice(outOf: 10, success: 1) {
//                    // 1/10 — донк-бет (но здесь герой уже поставил, так что коллим)
//                    return .call
//                } else {
//                    // 7/10 — чек/фолд
//                    return .call // или .fold если нет руки
//                }
//            } else {
//                // Герой не ставил → бот может донк-бетить
//                if rollDice(outOf: 10, success: 1) {
//                    // 1/10 — донк-бет
//                    let betSize = bankSize(board: board, hand: hand) * 3 / 10
//                    return .raise(max(betSize, 5))
//                } else if rollDice(outOf: 10, success: 7) {
//                    // 7/10 — чек
//                    return .check
//                } else {
//                    // 2/10 — ставка
//                    let betSize = bankSize(board: board, hand: hand) * 5 / 10
//                    return .raise(max(betSize, 5))
//                }
//            }
//        }
//        
//        return .check
//    }
//
//    private func bankSize(board: [Card], hand: [Card]) -> Int {
//        // Здесь нужно передавать текущий банк, но для простоты:
//        return 20 // заглушка
//    }
//    func decideActionTurn(board: [Card], hand: [Card]){
//        print("turn")
//    }
//    func decideActionRiver(board: [Card], hand: [Card], currentBet: Int = 0){
//        print("river")
//    }
    
enum BotAction {
    case fold
    case call
    case raise(Int)
    case check
}
}
