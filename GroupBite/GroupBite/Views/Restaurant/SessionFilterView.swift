import SwiftUI
import CoreLocation

struct SessionFilterView: View {
    @ObservedObject var sessionViewModel: GroupSessionViewModel
    @ObservedObject var locationManager: LocationManager
    let groupId: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var radius: Double = 5000
    @State private var priceLevel: Int = 0
    @State private var selectedTypes: Set<String> = ["restaurant"]
    @State private var searchQuery: String = ""
    @State private var isLoading = false
    @State private var locationStatus: String = "Checking location access..."
    
    private let restaurantTypes = [
        "restaurant", "cafe", "bar", "bakery", "pizza", 
        "sushi", "burger", "chinese", "italian", "mexican",
        "indian", "thai", "japanese", "korean", "vietnamese"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            headerView
            Divider().background(AppColors.border)
            
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // Location Status
                    locationStatusSection
                    
                    // Search Query
                    searchSection
                    
                    // Distance
                    distanceSection
                    
                    // Price Level
                    priceSection
                    
                    // Restaurant Types
                    typesSection
                    
                    // Action Buttons
                    actionButtons
                }
                .padding(AppSpacing.lg)
            }
        }
        .frame(minWidth: 500, minHeight: 600)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .onAppear {
            loadCurrentFilters()
            print("📍 SessionFilterView: onAppear - requesting location")
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.location) { location in
            if let location = location {
                print("📍 SessionFilterView: Location received: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                setupLocation()
            }
        }
        .onChange(of: locationManager.errorMessage) { error in
            if let error = error {
                print("📍 SessionFilterView: Location error: \(error)")
                setupLocation()
            }
        }
        .onChange(of: locationManager.authorizationStatus) { status in
            print("📍 SessionFilterView: Authorization status changed to: \(status.rawValue)")
            setupLocation()
        }
    }
    
    private func setupLocation() {
        print("📍 SessionFilterView: Setting up location...")
        
        // Update location status based on location manager state
        if let location = locationManager.location {
            locationStatus = "📍 Location: \(String(format: "%.4f", location.coordinate.latitude)), \(String(format: "%.4f", location.coordinate.longitude))"
        } else if let errorMessage = locationManager.errorMessage {
            locationStatus = "❌ Location error: \(errorMessage)"
        } else if locationManager.isRequestingLocation {
            locationStatus = "⏳ Getting your location..."
        } else {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationStatus = "🔒 Location permission needed"
            case .denied, .restricted:
                locationStatus = "❌ Location access denied"
            case .authorizedWhenInUse, .authorizedAlways:
                locationStatus = "✅ Location permission granted"
            @unknown default:
                locationStatus = "❓ Unknown location status"
            }
        }
    }
    
    private func openSystemPreferences() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Location") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private var locationStatusSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primary)
                
                Text("Your Location")
                    .font(AppTypography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(locationStatus)
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.surfaceSecondary)
                    .cornerRadius(AppCornerRadius.md)
                
                if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                    Button("Open System Preferences") {
                        openSystemPreferences()
                    }
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.primary)
                }
                
                if locationManager.authorizationStatus == .notDetermined {
                    Button("Request Location Permission") {
                        locationManager.requestPermission()
                    }
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.primary)
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Session Filters")
                .font(AppTypography.title1)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }
            .help("Close")
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.surface)
    }
    
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primary)
                
                Text("Search Query")
                    .font(AppTypography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            TextField("e.g., pizza, sushi, coffee...", text: $searchQuery)
                .textFieldStyle(ModernTextFieldStyle())
                .font(AppTypography.body)
        }
    }
    
    private var distanceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "location.circle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primary)
                
                Text("Search Radius")
                    .font(AppTypography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(spacing: AppSpacing.sm) {
                HStack {
                    Text("\(Int(radius/1000)) km")
                        .font(AppTypography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                }
                
                Slider(value: $radius, in: 1000...50000, step: 1000)
                    .accentColor(AppColors.primary)
            }
        }
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "dollarsign.circle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primary)
                
                Text("Price Level")
                    .font(AppTypography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            HStack(spacing: AppSpacing.sm) {
                ForEach(0...4, id: \.self) { level in
                    Button(action: { priceLevel = level }) {
                        Text(priceLevelText(level))
                            .font(AppTypography.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(priceLevel == level ? .white : AppColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(priceLevel == level ? AppColors.primary : AppColors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                            .cornerRadius(AppCornerRadius.md)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var typesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "fork.knife")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primary)
                
                Text("Restaurant Types")
                    .font(AppTypography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppSpacing.sm) {
                ForEach(restaurantTypes, id: \.self) { type in
                    Button(action: { toggleType(type) }) {
                        HStack {
                            Text(type.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(AppTypography.subheadline)
                                .foregroundColor(selectedTypes.contains(type) ? AppColors.primary : AppColors.textSecondary)
                            
                            Spacer()
                            
                            if selectedTypes.contains(type) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        .padding(AppSpacing.sm)
                        .background(selectedTypes.contains(type) ? AppColors.primary.opacity(0.1) : AppColors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                .stroke(selectedTypes.contains(type) ? AppColors.primary : AppColors.border, lineWidth: 1)
                        )
                        .cornerRadius(AppCornerRadius.sm)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    

    
    private var actionButtons: some View {
        VStack(spacing: AppSpacing.md) {
            PrimaryButton(isLoading ? "Starting Session..." : "Start Session", icon: "play.fill", isLoading: isLoading) {
                startSession()
            }
            
            SecondaryButton("Cancel", icon: "xmark") {
                dismiss()
            }
        }
    }
    
    private func priceLevelText(_ level: Int) -> String {
        switch level {
        case 0: return "Any"
        case 1: return "$"
        case 2: return "$$"
        case 3: return "$$$"
        case 4: return "$$$$"
        default: return "Any"
        }
    }
    
    private func toggleType(_ type: String) {
        if selectedTypes.contains(type) {
            selectedTypes.remove(type)
        } else {
            selectedTypes.insert(type)
        }
    }
    
    private func loadCurrentFilters() {
        if let session = sessionViewModel.currentSession {
            radius = session.filters.radius
            priceLevel = session.filters.priceLevel
            selectedTypes = Set(session.filters.types)
            searchQuery = session.filters.searchQuery
        }
    }
    
    private func startSession() {
        isLoading = true
        
        let filters = SessionFilters(
            radius: radius,
            priceLevel: priceLevel,
            types: Array(selectedTypes),
            searchQuery: searchQuery
        )
        
        Task {
            // Use the actual group ID passed to this view
            
            // Get current location
            let location = locationManager.location
            print("📍 SessionFilterView: Starting session with location: \(location?.description ?? "nil")")
            
            await sessionViewModel.createSession(
                for: groupId,
                filters: filters,
                location: location
            )
            
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        }
    }
}

#Preview {
    SessionFilterView(sessionViewModel: GroupSessionViewModel(), locationManager: LocationManager(), groupId: "preview_group_id")
} 