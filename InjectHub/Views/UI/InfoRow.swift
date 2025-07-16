//
//  InfoRow.swift
//  InjectHub
//
//  Created by NKR on 14/07/25.
//

import SwiftUI

struct ArchTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 11))
            .foregroundColor(.blue)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(4)
    }
}

struct InfoRow: View {
    let title: LocalizedStringKey
    let value: String
    let icon: String
    
    private var isArchRow: Bool {
        icon == "cpu"
    }
    
    private var architectures: [String] {
        guard isArchRow else { return [] }
        return value.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
            .components(separatedBy: "  ")
            .filter { !$0.isEmpty }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                if isArchRow {
                    FlowLayout(spacing: 6) {
                        ForEach(architectures, id: \.self) { arch in
                            ArchTag(text: arch)
                        }
                    }
                } else {
                    Text(value)
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var height: CGFloat = 0
        var width: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for (_, size) in sizes.enumerated() {
            if x + size.width > (proposal.width ?? .infinity) {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            
            x += size.width + spacing
            width = max(width, x)
            rowHeight = max(rowHeight, size.height)
            height = max(height, y + size.height)
        }
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        
        for (index, subview) in subviews.enumerated() {
            let size = sizes[index]
            
            if x + size.width > bounds.maxX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            
            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(size)
            )
            
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
