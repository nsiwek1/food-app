import SwiftUI
import CoreLocation

struct RestaurantSearchView: View {
    let group: Group
    @StateObject private var locationManager = LocationManager()
    @StateObject private var restaurantViewModel = RestaurantViewModel()
    
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var selectedRadius: Double = 5000 // 5km default
    @State private var selectedPriceLevel: Int = 2 // Moderate default
    @State private var selectedTypes: Set<String> = ["restaurant"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Header
            searchHeader
            
            // Restaurant Cards
            if restaurantViewModel.isLoading {
                loadingView
            } else if restaurantViewModel.restaurants.isEmpty {
                emptyStateView
            } else {
                restaurantCardsView
            }
        }
        .navigationTitle("Find Restaurants")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingFilters = true }) {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showingFilters) {
            FilterView(
                radius: $selectedRadius,
                priceLevel: $selectedPriceLevel,
                selectedTypes: $selectedTypes
            )
        }
        #else
        .sheet(isPresented: $showingFilters) {
            FilterView(
                radius: $selectedRadius,
                priceLevel: $selectedPriceLevel,
                selectedTypes: $selectedTypes
            )
            .frame(minWidth: 500, minHeight: 600)
        }
        #endif
        .onAppear {
            setupLocationAndSearch()
        }
        .onChange(of: searchText) { _, _ in
            searchRestaurants()
        }
    }
    
    private var searchHeader: some View {
        VStack(spacing: 16) {
            // Group Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.headline)
                    Text("\(group.members.count) members")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search restaurants...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Finding restaurants near you...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("No restaurants found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Adjust Filters") {
                showingFilters = true
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var restaurantCardsView: some View {
        TabView {
            ForEach(restaurantViewModel.restaurants) { restaurant in
                RestaurantCardView(
                    restaurant: restaurant,
                    onLike: { likeRestaurant(restaurant) },
                    onDislike: { dislikeRestaurant(restaurant) }
                )
            }
        }
        #if os(iOS)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        #else
        .tabViewStyle(DefaultTabViewStyle())
        #endif
    }
    
    private func setupLocationAndSearch() {
        locationManager.requestLocation()
        
        // Search for restaurants when location is available
        if let location = locationManager.location {
            searchRestaurants(location: location)
        }
    }
    
    private func searchRestaurants(location: CLLocation? = nil) {
        let searchLocation = location ?? locationManager.location
        
        guard let searchLocation = searchLocation else {
            // If no location, search with empty location (will use device location)
            Task {
                await restaurantViewModel.searchRestaurants(
                    query: searchText,
                    location: nil,
                    radius: selectedRadius,
                    priceLevel: selectedPriceLevel,
                    types: Array(selectedTypes)
                )
            }
            return
        }
        
        Task {
            await restaurantViewModel.searchRestaurants(
                query: searchText,
                location: searchLocation,
                radius: selectedRadius,
                priceLevel: selectedPriceLevel,
                types: Array(selectedTypes)
            )
        }
    }
    
    private func likeRestaurant(_ restaurant: Restaurant) {
        // TODO: Implement like functionality
        print("Liked restaurant: \(restaurant.name)")
    }
    
    private func dislikeRestaurant(_ restaurant: Restaurant) {
        // TODO: Implement dislike functionality
        print("Disliked restaurant: \(restaurant.name)")
    }
}

struct RestaurantCardView: View {
    let restaurant: Restaurant
    let onLike: () -> Void
    let onDislike: () -> Void
    
    @State private var offset = CGSize.zero
    @State private var showingDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Restaurant Image
            ZStack {
                if let photoReference = restaurant.photoReference {
                    AsyncImage(url: APIConfig.photoURL(photoReference: photoReference)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "fork.knife.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "fork.knife.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                }
                
                // Like/Dislike indicators
                HStack {
                    VStack {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                            .opacity(offset.width < 0 ? Double(-offset.width / 50) : 0)
                        Spacer()
                    }
                    Spacer()
                    VStack {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                            .opacity(offset.width > 0 ? Double(offset.width / 50) : 0)
                        Spacer()
                    }
                }
                .padding()
            }
            .frame(height: 300)
            .clipped()
            
            // Restaurant Info
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(restaurant.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(2)
                        
                        Text(restaurant.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        if let rating = restaurant.rating {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Text(String(format: "%.1f", rating))
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        if let priceLevel = restaurant.priceLevel {
                            Text(String(repeating: "$", count: priceLevel))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(restaurant.types.prefix(5), id: \.self) { type in
                            Text(type.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                        }
                    }
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: onDislike) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                    }
                    
                    Button(action: { showingDetails = true }) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: onLike) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        .offset(x: offset.width, y: offset.height)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { gesture in
                    withAnimation(.spring()) {
                        if abs(gesture.translation.width) > 100 {
                            if gesture.translation.width > 0 {
                                onLike()
                            } else {
                                onDislike()
                            }
                        }
                        offset = .zero
                    }
                }
        )
        .sheet(isPresented: $showingDetails) {
            RestaurantDetailView(restaurant: restaurant)
        }
    }
}

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var radius: Double
    @Binding var priceLevel: Int
    @Binding var selectedTypes: Set<String>
    
    private let restaurantTypes = [
        "restaurant", "cafe", "bar", "bakery", "pizza", 
        "sushi", "burger", "chinese", "italian", "mexican",
        "indian", "thai", "japanese", "korean", "vietnamese"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Distance") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Radius: \(Int(radius/1000))km")
                            Spacer()
                        }
                        
                        Slider(value: $radius, in: 1000...50000, step: 1000)
                    }
                }
                
                Section("Price Level") {
                    Picker("Price Level", selection: $priceLevel) {
                        Text("Any").tag(0)
                        Text("$").tag(1)
                        Text("$$").tag(2)
                        Text("$$$").tag(3)
                        Text("$$$$").tag(4)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Restaurant Types") {
                    ForEach(restaurantTypes, id: \.self) { type in
                        HStack {
                            Text(type.replacingOccurrences(of: "_", with: " ").capitalized)
                            Spacer()
                            if selectedTypes.contains(type) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedTypes.contains(type) {
                                selectedTypes.remove(type)
                            } else {
                                selectedTypes.insert(type)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RestaurantSearchView(group: Group(
        name: "Test Group",
        description: "A test group",
        createdBy: "user1"
    ))
} 