//
//  LearnView.swift
//  VillageFor
//
//  Created by Srinadh Tanugonda on 10/24/25.
//

import SwiftUI

struct LearnView: View {
    @StateObject private var viewModel: LearnViewModel
    @FocusState private var isSearchFocused: Bool
    @EnvironmentObject var sessionManager: SessionManager
    
    private let categories = ["Mental health", "Physical health", "Community"]
    
    // MARK: - Init
    init(articles: [Article]? = nil) {
        if let articles = articles {
            _viewModel = StateObject(wrappedValue: LearnViewModel(mockArticles: articles))
        } else {
            _viewModel = StateObject(wrappedValue: LearnViewModel())
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: Header + Inline Search
            ZStack {
                // Title and Magnifying Glass
                HStack {
                    Text("Learn")
                        .font(.largeTitle.bold())
                        .opacity(isSearchFocused ? 0 : 1)
                        .animation(.easeInOut(duration: 0.25), value: isSearchFocused)
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isSearchFocused = true
                        }
                        
                        // Delay focus to trigger keyboard
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isSearchFocused = true
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(6)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    .opacity(isSearchFocused ? 0 : 1)
                    .animation(.easeInOut(duration: 0.25), value: isSearchFocused)
                }
                .padding(.horizontal)
                
                // Search Bar + Cancel
                HStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search...", text: $viewModel.searchQuery)
                            .focused($isSearchFocused)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled(true)
                            .onChange(of: viewModel.searchQuery) { _ in
                                viewModel.applyFilters()
                            }
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isSearchFocused = true
                                }
                            }
                        
                        if !viewModel.searchQuery.isEmpty {
                            Button {
                                viewModel.searchQuery = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    Button("Cancel") {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isSearchFocused = false
                            viewModel.searchQuery = ""
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                            to: nil, from: nil, for: nil)
                        }
                    }
                    .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .opacity(isSearchFocused ? 1 : 0)
                .animation(.easeInOut(duration: 0.25), value: isSearchFocused)
            }
            .padding(.top, 10)
            
            // MARK: Category Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectCategory(category)
                            }
                        } label: {
                            Text(category)
                                .font(.system(size: 15, weight: .medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(viewModel.selectedCategory == category
                                              ? Color("ThemeGreen").opacity(0.15)
                                              : Color.clear)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            viewModel.selectedCategory == category
                                            ? Color("ThemeGreen")
                                            : Color.gray.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                        }
                        .foregroundColor(
                            viewModel.selectedCategory == category
                            ? Color("ThemeGreen")
                            : .primary
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // MARK: Article List
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.isLoading {
                        ProgressView("Loading…")
                            .padding(.top, 50)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else if viewModel.filteredArticles.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No articles found")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ForEach(viewModel.filteredArticles) { article in
                            ArticleCard(article: article)
                        }
                    }
                }
                .padding(.horizontal)
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .background(Color("LightGrayBG").ignoresSafeArea())
        .onAppear {
            if viewModel.filteredArticles.isEmpty {
                viewModel.applyFilters()
            }
        }
        .onTapGesture {
            if isSearchFocused {
                isSearchFocused = false
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                to: nil, from: nil, for: nil)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                sessionManager.isTabBarHidden = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                sessionManager.isTabBarHidden = false
            }
        }
    }
}

#Preview("LearnView Preview") {
    let mockArticles = [
        Article(id: "1", title: "Coping with Postpartum Anxiety",
                subtitle: "Mindfulness tips for mothers",
                content: "Details here...",
                imageURL: "https://images.unsplash.com/photo-1607746882042-944635dfe10e",
                category: "Mental health", createdAt: Date())
    ]
    
    NavigationStack {
        LearnView(articles: mockArticles)
            .environmentObject(SessionManager())
    }
    .environment(\.colorScheme, .light)
}
