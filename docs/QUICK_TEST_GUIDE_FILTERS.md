# 🧪 Quick Testing Guide - Advanced Product Filters

## ⚡ Quick Start (5 Minutes)

### 1. **Start the Backend** (1 min)
```bash
cd albaqer_gemstone_backend
node server.js
```
✅ Look for: "✅ Server running on port 3000"

### 2. **Run Flutter App** (1 min)
```bash
cd albaqer_gemstone_flutter
flutter run
```

### 3. **Navigate to Shop Screen** (5 seconds)
- Tap **Shop** icon in bottom navigation

### 4. **Test Basic Filter UI** (1 min)
- Look for tune icon (🎛️) next to filter icon in top bar
- Tap the **tune icon**
- ✅ **Expected:** Bottom sheet opens with all filters

### 5. **Apply Your First Filter** (2 min)
Follow this exact sequence:

**Step 1:** Move price slider to $100 - $500  
**Step 2:** Tap "Ring" category chip  
**Step 3:** Select "Agate" from gemstone dropdown  
**Step 4:** Tap "Men" gender chip  
**Step 5:** Tap **"Apply (4)"** button  

✅ **Expected Results:**
- Sheet closes
- Products update
- See 4 filter chips at top: `[Price: $100-$500 ✕] [ring ✕] [agate ✕] [men ✕]`
- Tune icon shows badge with "4"
- Only matching products displayed

### 6. **Remove a Filter** (30 seconds)
- Tap the **X** on "ring" chip
- ✅ **Expected:** Products reload without ring filter

### 7. **Clear All Filters** (10 seconds)
- Tap **"Clear All"** button
- ✅ **Expected:** All products show again, chips disappear

---

## 🎯 Test Scenarios

### Scenario 1: Price Filter Only
```
1. Open filters
2. Set price: $200 - $1000
3. Apply
Expected: Only products in that price range
```

### Scenario 2: Islamic Significance
```
1. Open filters
2. Scroll to Islamic Significance
3. Tap "Sunnah" chip
4. Apply
Expected: Only products with sunnah tag (likely Agate stones)
```

### Scenario 3: In Stock Only
```
1. Open filters
2. Toggle "In Stock Only" ON
3. Apply
Expected: Only products with quantity > 0
```

### Scenario 4: Rating Filter
```
1. Open filters
2. Scroll to Minimum Rating
3. Select "4+ Stars"
4. Apply
Expected: Only products with rating >= 4.0
```

### Scenario 5: Size Filter (Context-Aware)
```
1. Open filters
2. Select category "Ring"
3. Scroll to Size section
4. Select size "8"
5. Apply
Expected: Ring sizes 6-12 shown in dropdown, only size 8 rings displayed
```

### Scenario 6: Combined Filters
```
1. Open filters
2. Price: $100 - $500
3. Category: Ring
4. Gender: Men
5. Metal: Gold
6. In Stock: ON
7. Rating: 4+ Stars
8. Apply
Expected: Only men's gold rings $100-$500, in stock, rated 4+
```

---

## ❌ Error Testing

### Test Empty Results:
```
1. Set price: $1 - $5
2. Apply
Expected: "No products found" message or empty grid
```

### Test Clear All:
```
1. Apply multiple filters
2. Tap "Clear All" in active filters section
Expected: All chips removed, all products shown
```

### Test Individual Chip Removal:
```
1. Apply 5 different filters
2. Remove each chip one by one
Expected: Products update after each removal
```

---

## 🐛 Bug Checklist

While testing, watch for:

- [ ] ❌ Bottom sheet doesn't open
- [ ] ❌ Filters don't apply
- [ ] ❌ Products don't update after applying
- [ ] ❌ Chips don't display
- [ ] ❌ Badge count wrong
- [ ] ❌ Clear all doesn't work
- [ ] ❌ Chip removal doesn't reload
- [ ] ❌ Price slider doesn't move
- [ ] ❌ Dropdown doesn't show options
- [ ] ❌ Size filter shows when no category selected
- [ ] ❌ API errors in console
- [ ] ❌ App crashes

---

## 📊 Expected Console Output

### When Applying Filters:
```
🔍 Fetching filtered products...
📦 GET /api/products?minPrice=100&maxPrice=500&category=ring&gender=men
✅ Filtered products loaded: 12 results
```

### When Removing Filter:
```
🔄 Filter removed: category
📦 Reloading filtered products...
✅ Updated products: 45 results
```

### When Clearing All:
```
🧹 Clearing all filters
📦 Loading all products...
✅ All products loaded: 120 results
```

---

## ✅ Success Criteria

You've successfully tested if:

1. ✅ Bottom sheet opens smoothly
2. ✅ All filter types are visible
3. ✅ Filters can be selected/changed
4. ✅ "Apply" button shows correct count
5. ✅ Products update after applying
6. ✅ Active filter chips display
7. ✅ Badge shows correct count
8. ✅ Individual chips can be removed
9. ✅ Clear All works
10. ✅ No errors in console

---

## 🚀 Quick Performance Check

### Test with Maximum Filters:
```
Apply ALL filters:
- Price range
- Category
- Gemstone
- Gender
- Color
- Metal
- In Stock
- Islamic tag
- Rating
- Size

Expected: Results load in < 2 seconds
```

---

## 📝 Report Issues

If you find bugs, note:
1. **What you did** (steps to reproduce)
2. **What you expected** (correct behavior)
3. **What happened** (actual behavior)
4. **Console errors** (if any)

---

## 🎉 Done!

If all tests pass, the filter system is **PRODUCTION READY** ✅

**Time Required:** 15-20 minutes for thorough testing  
**Next Step:** Commit and tag as v1.7.0

---

**Quick Commands:**
```bash
# Backend
cd albaqer_gemstone_backend && node server.js

# Flutter
cd albaqer_gemstone_flutter && flutter run

# Check API
curl "http://192.168.0.106:3000/api/products?minPrice=100&maxPrice=500"
```
