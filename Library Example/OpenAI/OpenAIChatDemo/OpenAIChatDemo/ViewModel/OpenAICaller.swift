//
//  OpenAICaller.swift
//  OpenAIChatDemo
//
//  Created by Dev on 18/12/2567 BE.
//

import Foundation
import OpenAISwift
import Tiktoken

class OpenAICaller {
    
    private var client: OpenAISwift?
    private var chatHistory: [ChatMessage] = [] // All Chat
    private (set) var chatUIHistory: [ChatMessage] = [] // All Chat
    
    @frozen enum Constants {
        static let key = ""
        static let modelLLM: OpenAIModelType = .chat(.chatgpt)
    }
    
    init() {
        self.client = OpenAISwift(authToken: Constants.key, config: .init())
    }
    
    private let systemRole = ChatMessage(
        role: .system,
        content: "You are a financial planning assistant. You specialize in giving advice about budgeting, investments, savings, and retirement planning. Avoid answering questions unrelated to financial topics."
    )
    public func prepareChat() {
        if chatHistory.isEmpty {
            chatUIHistory.append(systemRole)
            chatHistory.append(systemRole)
        }
    }
}

// MARK: getReponse Chat
extension OpenAICaller {
    public func getReponse(input: String, completion: @escaping(Result<Bool, Error>) -> Void) {
        
        
        chatHistory.append(ChatMessage(role: .user, content: input))
        chatUIHistory.append(ChatMessage(role: .user, content: input))
        
        /*
         // สำหรับทดสอบแบบไม่ยิง service
         chatHistory.append(ChatMessage(role: .assistant, content: TestMessage.shared.randomMessage()))
         chatUIHistory.append(ChatMessage(role: .assistant, content: TestMessage.shared.randomMessage()))
         */
        manageChatHistory(maxTokens: 4000) // max = 4096 ref ChatGPT
        // Request chat normal
        client?.sendChat(
            with: chatHistory,
            model: Constants.modelLLM,
            temperature: 0.5,
            maxTokens: 150,
            completionHandler: { [weak self] resultChat in
                guard let self = self else {
                    return
                }
                switch resultChat {
                case .success(let model):
                    guard let modelChat = model.choices?.first?.message else {
                        return
                    }
                   print("modelChat -> \(modelChat)")
                    chatHistory.append(modelChat)
                   chatUIHistory.append(modelChat)
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
    }
}

// MARK: ManageChat history
extension OpenAICaller {
    // ฟังก์ชันหลักในการจัดการประวัติแชทก่อนส่งไปยังโมเดล
    private func manageChatHistory(maxTokens: Int) {
        retainImportantMessages()
        
        Task { // ย้ายไปทำ background ไม่เกี่ยวกับ UI
            // สรุปข้อความเก่าเลือกใช้วิธีการแบบ Local ที่กำลังทำอยู่หรือจะเลือกสร้าง LLM อีกตัวมาทำการสรุปข้อมูลแชทก็ได้
            await summarizeOldMessagesIfNeeded(maxTokens: maxTokens)
        }
    }
    
    private func retainImportantMessages() {
        let systemMessages = chatHistory.filter { $0.role == .system }
        let latestMessages = chatHistory.filter { $0.role != .system }
        chatHistory = Array(systemMessages.prefix(1)) + latestMessages
    }

    // สรุปข้อความเก่า (ใช้ข้อความใหม่แทนข้อความเก่า)
    private func summarizeOldMessagesIfNeeded(maxTokens: Int) async {
        guard chatHistory.count > 20 else {
            return
        }
        
        // สร้างข้อความสรุป
        let summaryContent = chatHistory
            .dropFirst(1) // ไม่รวมข้อความ `system`
            .dropLast(10) // ไม่รวมข้อความล่าสุด
            .filter { !$0.content.isEmpty }
            .map { "\($0.role == .user ? "User" : "Assistant"): \($0.content)" }
            .joined(separator: " ")
        let summaryMessage = ChatMessage(role: .system, content: "Conversation summary: \(summaryContent)")
        chatHistory = [chatHistory.first!] + [summaryMessage] + chatHistory.suffix(10)
        #if DEBUG
        for item in chatHistory {
            print("itemDetail After Drop -> \(item.role): \(item.content)")
        }
        #endif
        
        if let haveTokens = await calculateChatTokens(model: Constants.modelLLM), haveTokens > maxTokens {
            await trimChatHistoryByTokenLimit(maxTokens: maxTokens)
        }
    }

    private func calculateChatTokens(model: OpenAIModelType) async -> Int? {
        do {
            guard let encoder = try await Tiktoken.shared.getEncoding(model.modelName) else {
                print("Error: Unable to get encoding for model \(model)")
                return nil
            }
            
            let calToken = chatHistory.reduce(0) { total, message in
                total + (encoder.encode(value: message.content).count)
            }
            
            return calToken
        } catch {
            print("Error encoding chat messages: \(error)")
            return nil
        }
    }
    
    private func trimChatHistoryByTokenLimit(maxTokens: Int) async {
#if DEBUG
        print("before drop \(chatHistory)")
#endif
        while let tokenCount = await calculateChatTokens(model: Constants.modelLLM),
                  tokenCount > maxTokens,
              !chatHistory.isEmpty {
            if let indexToRemove = chatHistory.firstIndex(where: { $0.role != .system }) {
                chatHistory.remove(at: indexToRemove)
            } else {
                break
            }
            #if DEBUG
            print("trimChatHistoryByTokenLimit -> tokenCount:  \(tokenCount), maxTokens: \(maxTokens)")
            #endif
        }
#if DEBUG
        print("after remove \(chatHistory)")
#endif
    }
}
