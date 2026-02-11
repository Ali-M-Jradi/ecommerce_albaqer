# 🗺️ Implementation Roadmap - AlBaqer Gemstone E-Commerce

**Project Status:** Phase 1 Complete ✅ | Phase 2 Ready 🟠  
**Last Updated:** February 11, 2026  
**Total Issues Identified:** 31  
**Completed:** 4 critical issues (P0-1, P0-2, P0-3, P0-4)

---

## 📊 Priority Classification

### 🔴 **P0 - CRITICAL** (Must Fix Immediately)
These issues block core functionality and must be fixed before production.

### 🟠 **P1 - HIGH** (Next Sprint)
Important features that significantly impact user experience.

### 🟡 **P2 - MEDIUM** (Future Sprints)
Enhancements that improve usability and completeness.

### 🟢 **P3 - LOW** (Nice to Have)
Polish and optional features for future releases.

---

## 🔴 PHASE 1: CRITICAL FIXES (Week 1-2)
**Goal:** Fix blocking issues preventing core e-commerce functionality

### P0-1: Address Management System ⏱️ 3-4 days ✅ COMPLETED
**Priority:** CRITICAL - Blocks order creation  
**Issue #2:** Address backend endpoints missing

**Tasks:**
- [x] Create `addressController.js` with CRUD operations
- [x] Create `addressRoutes.js` (GET, POST, PUT, DELETE)
- [x] Add address validation middleware
- [x] Create Flutter address screens (list, add/edit)
- [x] Update checkout flow with address selection
- [x] Test address creation and retrieval
- [x] Verify order creation with addresses works

**Files Created:**
- `albaqer_gemstone_backend/controllers/addressController.js`
- `albaqer_gemstone_backend/routes/addressRoutes.js`
- `albaqer_gemstone_backend/middleware/validation.js` (updated)
- `albaqer_gemstone_flutter/lib/screens/addresses_screen.dart`
- `albaqer_gemstone_flutter/lib/screens/add_edit_address_screen.dart`
- `albaqer_gemstone_flutter/lib/services/address_service.dart` (updated)

**Dependencies:** None  
**Impact:** CRITICAL - Order confirmation currently failing

**Status:** ✅ Completed - Backend and Flutter UI fully implemented

---

### P0-2: Order Status Update Error Fix ⏱️ 1-2 days ✅ COMPLETED
**Priority:** CRITICAL - Admin can't manage orders  
**Issue #6:** Order confirmation fails in admin panel

**Tasks:**
- [x] Add detailed error logging in `orderController.js`
- [x] Check database status column constraints
- [x] Verify status values match schema
- [x] Add better error messages in Flutter
- [x] Test all status transitions

**Files Modified:**
- `albaqer_gemstone_backend/controllers/orderController.js` - Enhanced error handling
- `albaqer_gemstone_flutter/lib/services/order_service.dart` - Better error messages
- `albaqer_gemstone_flutter/lib/screens/profile_screen.dart` - Updated status colors
- `albaqer_gemstone_flutter/lib/repositories/order_repository.dart` - Updated status references
- `albaqer_gemstone_backend/fix_status_constraint.sql` - Applied database fix

**Files Created:**
- `albaqer_gemstone_backend/tests/test_order_status_updates.js` - Automated tests
- `albaqer_gemstone_backend/tests/MANUAL_TESTING_ORDER_STATUS.md` - Testing guide
- `docs/P0-2_ORDER_STATUS_FIX_SUMMARY.md` - Complete fix documentation

**Dependencies:** None  
**Impact:** CRITICAL - Admin workflow blocked

**Status:** ✅ Completed - Database constraint fixed, error handling improved, testing resources created

---

### P0-3: Stock Management on Order ⏱️ 2-3 days ✅ COMPLETED
**Priority:** CRITICAL - Prevent overselling  
**Issue #13:** No stock reduction when orders created

**Tasks:**
- [x] Add stock validation before order creation
- [x] Add stock decrement in `createOrder` controller
- [x] Add transaction handling for atomicity
- [x] Add stock restoration on order cancellation
- [x] Add stock restoration on order deletion
- [x] Add low stock monitoring endpoint

**Files Modified:**
- `albaqer_gemstone_backend/controllers/orderController.js` - Enhanced order creation, status update, and deletion
- `albaqer_gemstone_backend/routes/orderRoutes.js` - Added `/inventory/low-stock` route

**Files Created:**
- `albaqer_gemstone_backend/tests/test_stock_management.js` - Comprehensive automated tests
- `docs/P0-3_STOCK_MANAGEMENT_SUMMARY.md` - Complete implementation documentation

**Features Added:**
- ✅ Pre-order stock validation (prevents overselling)
- ✅ Automatic stock decrement on order creation
- ✅ Automatic stock restoration on order cancellation
- ✅ Automatic stock restoration on order deletion
- ✅ Low stock monitoring with categorization (out_of_stock, critical, low, warning)
- ✅ Transaction-safe operations with rollback on error
- ✅ Detailed console logging for debugging
- ✅ Comprehensive error messages with stock details

**Dependencies:** None  
**Impact:** HIGH - Products can be oversold

**Status:** ✅ Completed - Full stock management system implemented with automated testing

---

### P0-4: Stock Display & Cart Logic Bug Fixes ⏱️ 1-2 days ✅ COMPLETED
**Priority:** CRITICAL - Prevents adding available products to cart  
**Issues:** Multiple bugs discovered during P0-3 testing

**Tasks:**
- [x] Remove isAvailable boolean check blocking valid products
- [x] Implement getAvailableStock() method (total - in cart)
- [x] Update product detail screen with cart-aware stock display
- [x] Update shop screen to show available stock, not total
- [x] Add cache invalidation on all checkout attempts
- [x] Implement auto-reload on screen resume
- [x] Parse detailed stock_issues from backend 400 responses

**Files Modified:**
- `albaqer_gemstone_flutter/lib/services/cart_service.dart` - Removed isAvailable check, added getAvailableStock()
- `albaqer_gemstone_flutter/lib/screens/product_detail_screen.dart` - Cart-aware stock display
- `albaqer_gemstone_flutter/lib/screens/shop_screen.dart` - Added didChangeDependencies, auto-reload
- `albaqer_gemstone_flutter/lib/screens/cart_screen.dart` - Cache clear on all checkout attempts
- `albaqer_gemstone_flutter/lib/services/order_service.dart` - Parse stock_issues array

**Bug Fixes:**
- ✅ Fixed: Product with 2 stock but isAvailable=false couldn't be added to cart
- ✅ Fixed: Available stock calculation didn't account for items in cart
- ✅ Fixed: Shop screen didn't refresh after order completion
- ✅ Fixed: Generic error messages when stock validation failed
- ✅ Fixed: Cart items not immediately cleared after successful order

**Features Added:**
- ✅ "All in cart" indicator when availableStock = 0 but items in cart
- ✅ "X in your cart" subtitle on product detail screen
- ✅ Detailed stock error logging with product names and quantities
- ✅ Auto-refresh shop screen when cache is stale

**Dependencies:** P0-3 Stock Management  
**Impact:** CRITICAL - User experience and order flow

**Status:** ✅ Completed - All bugs fixed, comprehensive flow verification

---

## 🟠 PHASE 2: CORE FEATURES (Week 3-4)
**Goal:** Implement essential missing backend systems

### P1-1: Reviews System ⏱️ 3-4 days
**Priority:** HIGH - Product reviews expected by users  
**Issue #1:** Reviews backend completely missing

**Tasks:**
- [ ] Create `reviewController.js` with full CRUD
- [ ] Create `reviewRoutes.js`
- [ ] Add review validation (rating 1-5, verify purchase)
- [ ] Update product rating calculation on new review
- [ ] Test with existing Flutter service

**Files to Create:**
- `albaqer_gemstone_backend/controllers/reviewController.js`
- `albaqer_gemstone_backend/routes/reviewRoutes.js`

**Dependencies:** None  
**Impact:** HIGH - User trust and engagement

---

### P1-2: Payment Gateway Integration ⏱️ 5-7 days
**Priority:** HIGH - No real payment processing  
**Issue #5:** Payment system not implemented

**Tasks:**
- [ ] Research and choose payment gateway (Stripe/PayPal)
- [ ] Create `paymentController.js`
- [ ] Create `paymentRoutes.js`
- [ ] Integrate Stripe API (recommended)
- [ ] Add payment webhook handling
- [ ] Update Flutter order flow with payment step
- [ ] Test sandbox transactions

**Files to Create:**
- `albaqer_gemstone_backend/controllers/paymentController.js`
- `albaqer_gemstone_backend/routes/paymentRoutes.js`
- `albaqer_gemstone_flutter/lib/screens/payment_screen.dart`
- `albaqer_gemstone_flutter/lib/services/payment_service.dart`

**Dependencies:** Address system complete  
**Impact:** CRITICAL for production - No revenue without this

---

### P1-3: Cart Sync Backend ⏱️ 2-3 days
**Priority:** HIGH - Multi-device experience  
**Issue #3:** Cart not synced to backend

**Tasks:**
- [ ] Create `cartController.js`
- [ ] Create `cartRoutes.js`
- [ ] Update Flutter CartService to sync with backend
- [ ] Add cart migration from local to backend
- [ ] Test cart persistence across devices

**Files to Create:**
- `albaqer_gemstone_backend/controllers/cartController.js`
- `albaqer_gemstone_backend/routes/cartRoutes.js`

**Files to Modify:**
- `albaqer_gemstone_flutter/lib/services/cart_service.dart`

**Dependencies:** None  
**Impact:** MEDIUM - Better UX for multi-device users

---

### P1-4: Wishlist Sync Backend ⏱️ 2 days
**Priority:** MEDIUM - Enhancement  
**Issue #4:** Wishlist not synced

**Tasks:**
- [ ] Create `wishlistController.js`
- [ ] Create `wishlistRoutes.js`
- [ ] Update Flutter WishlistService to use backend
- [ ] Add wishlist migration from local storage

**Files to Create:**
- `albaqer_gemstone_backend/controllers/wishlistController.js`
- `albaqer_gemstone_backend/routes/wishlistRoutes.js`

**Files to Modify:**
- `albaqer_gemstone_flutter/lib/services/wishlist_service.dart`

**Dependencies:** None  
**Impact:** LOW - Nice to have for user experience

---

## 🟡 PHASE 3: ROLE-BASED FEATURES (Week 5-6)
**Goal:** Complete manager and delivery workflows

### P1-5: Manager Dashboard & Order Assignment ⏱️ 4-5 days
**Priority:** HIGH - Backend ready, UI missing  
**Issue #7:** Manager features incomplete

**Tasks:**
- [ ] Create `manager_dashboard_screen.dart`
- [ ] Create `manager_orders_screen.dart`
- [ ] Create `assign_delivery_screen.dart`
- [ ] Add manager role detection in auth flow
- [ ] Add manager navigation in drawer
- [ ] Test order assignment workflow

**Files to Create:**
- `albaqer_gemstone_flutter/lib/screens/manager_dashboard_screen.dart`
- `albaqer_gemstone_flutter/lib/screens/manager_orders_screen.dart`
- `albaqer_gemstone_flutter/lib/screens/assign_delivery_screen.dart`

**Dependencies:** Order status fix complete  
**Impact:** HIGH - Manager workflow automated

---

### P1-6: Delivery Man App/Screens ⏱️ 5-6 days
**Priority:** HIGH - Complete delivery workflow  
**Issue #8:** Delivery features missing

**Tasks:**
- [ ] Create `delivery_dashboard_screen.dart`
- [ ] Create `delivery_orders_screen.dart`
- [ ] Create `delivery_map_screen.dart` (optional)
- [ ] Add delivery role detection
- [ ] Add status update from delivery side
- [ ] Test full delivery workflow

**Files to Create:**
- `albaqer_gemstone_flutter/lib/screens/delivery_dashboard_screen.dart`
- `albaqer_gemstone_flutter/lib/screens/delivery_orders_screen.dart`

**Dependencies:** Manager features complete  
**Impact:** HIGH - Complete order fulfillment

---

## 🟡 PHASE 4: PRODUCT & SEARCH ENHANCEMENTS (Week 7-8)
**Goal:** Improve product discovery and management

### P2-1: Advanced Search & Filters ⏱️ 3-4 days
**Priority:** MEDIUM - Better product discovery  
**Issue #22:** Basic search only

**Tasks:**
- [ ] Add advanced filters to backend (price, rating, type)
- [ ] Create filter widget in Flutter
- [ ] Add sort options (price, rating, newest)
- [ ] Add search history
- [ ] Implement search suggestions

**Files to Modify:**
- `albaqer_gemstone_backend/controllers/productController.js`
- `albaqer_gemstone_flutter/lib/screens/shop_screen.dart`

**Dependencies:** None  
**Impact:** MEDIUM - Better user experience

---

### P2-2: Product Categories Management ⏱️ 2-3 days
**Priority:** MEDIUM - Better organization  
**Issue #9:** Category management incomplete

**Tasks:**
- [ ] Create category CRUD in admin panel
- [ ] Add category assignment to products
- [ ] Update shop screen with category filters
- [ ] Add category images

**Files to Create:**
- `albaqer_gemstone_flutter/lib/screens/admin_categories_screen.dart`

**Dependencies:** None  
**Impact:** MEDIUM - Better product organization

---

### P2-3: Gemstone Scan Backend ⏱️ 5-7 days
**Priority:** MEDIUM - Unique feature  
**Issue #10:** Image recognition not implemented

**Tasks:**
- [ ] Research gemstone image recognition APIs
- [ ] Create Python/Node ML service for identification
- [ ] Create `/api/gemstone/scan` endpoint
- [ ] Integrate with existing Flutter screen
- [ ] Train/fine-tune model with gemstone dataset

**Files to Create:**
- `albaqer_gemstone_backend/services/gemstoneRecognition.js` or Python service

**Dependencies:** Requires ML expertise  
**Impact:** LOW - Unique selling point but complex

---

### P2-4: Best Sellers Analytics ⏱️ 2 days
**Priority:** MEDIUM - Accurate business data  
**Issue #12:** Using reviews instead of real sales

**Tasks:**
- [ ] Create analytics query from order_items
- [ ] Add `/api/analytics/best-sellers` endpoint
- [ ] Update dashboard to use real sales data
- [ ] Add time range filters (week, month, year)

**Files to Modify:**
- `albaqer_gemstone_flutter/lib/services/product_service.dart`
- `albaqer_gemstone_backend/controllers/productController.js`

**Dependencies:** None  
**Impact:** MEDIUM - Better business insights

---

## 🟡 PHASE 5: USER EXPERIENCE (Week 9-10)
**Goal:** Polish user-facing features

### P1-7: Order Tracking Enhancement ⏱️ 3-4 days
**Priority:** MEDIUM - Better customer service  
**Issue #20:** Basic tracking only

**Tasks:**
- [ ] Add detailed order timeline view
- [ ] Add estimated delivery date calculation
- [ ] Implement push notifications (Firebase)
- [ ] Add order tracking page with real-time updates
- [ ] Optional: Add map view for delivery location

**Files to Create:**
- `albaqer_gemstone_flutter/lib/screens/order_tracking_screen.dart`
- Firebase Cloud Messaging setup

**Dependencies:** Delivery features complete  
**Impact:** HIGH - Customer satisfaction

---

### P2-5: User Profile Management ⏱️ 3 days
**Priority:** MEDIUM - Account management  
**Issue #21:** Basic profile only

**Tasks:**
- [ ] Add profile photo upload (backend + Flutter)
- [ ] Create change password screen
- [ ] Add email verification flow
- [ ] Add account deletion option
- [ ] Implement image upload to cloud storage

**Files to Create:**
- `albaqer_gemstone_flutter/lib/screens/edit_profile_screen.dart`
- `albaqer_gemstone_flutter/lib/screens/change_password_screen.dart`

**Dependencies:** None  
**Impact:** MEDIUM - User account control

---

### P2-6: Order History Enhancement ⏱️ 2 days
**Priority:** MEDIUM - Better order management  
**Issue #23:** Basic list only

**Tasks:**
- [ ] Add order items details in list view
- [ ] Add reorder functionality
- [ ] Generate PDF invoice/receipt
- [ ] Add order cancellation by user
- [ ] Add order search and filters

**Files to Modify:**
- `albaqer_gemstone_flutter/lib/screens/profile_screen.dart`

**Dependencies:** None  
**Impact:** MEDIUM - Improved user experience

---

## 🟢 PHASE 6: SECURITY & COMPLIANCE (Week 11-12)
**Goal:** Production-ready security

### P1-8: JWT Token Refresh ⏱️ 2 days
**Priority:** HIGH - Better session management  
**Issue #16:** No token refresh

**Tasks:**
- [ ] Implement refresh token mechanism
- [ ] Add token refresh endpoint
- [ ] Update Flutter auth to auto-refresh
- [ ] Add secure refresh token storage

**Files to Modify:**
- `albaqer_gemstone_backend/controllers/userController.js`
- `albaqer_gemstone_flutter/lib/services/auth_service.dart`

**Dependencies:** None  
**Impact:** HIGH - Better security and UX

---

### P2-7: Enhanced Validation ⏱️ 2-3 days
**Priority:** MEDIUM - Data integrity  
**Issue #17:** Inconsistent validation

**Tasks:**
- [ ] Add comprehensive form validation in Flutter
- [ ] Add phone number format validation
- [ ] Add email verification flow
- [ ] Add password strength requirements UI
- [ ] Implement client and server-side validation

**Files to Modify:**
- Multiple screen files with forms

**Dependencies:** None  
**Impact:** MEDIUM - Data quality

---

### P2-8: API Security Enhancements ⏱️ 3-4 days
**Priority:** MEDIUM - Production readiness  
**Issue #28:** Missing security features

**Tasks:**
- [ ] Implement rate limiting (express-rate-limit)
- [ ] Add request size limits
- [ ] Add helmet.js for security headers
- [ ] Implement CORS properly
- [ ] Add request logging

**Files to Modify:**
- `albaqer_gemstone_backend/server.js`
- `albaqer_gemstone_backend/middleware/security.js` (new)

**Dependencies:** None  
**Impact:** HIGH - Production security

---

### P3-1: Privacy & Compliance ⏱️ 2-3 days
**Priority:** LOW - Legal requirements  
**Issue #29:** Missing privacy features

**Tasks:**
- [ ] Create privacy policy screen
- [ ] Create terms of service screen
- [ ] Add GDPR compliance (data export, deletion)
- [ ] Add cookie consent (if web)

**Files to Create:**
- `albaqer_gemstone_flutter/lib/screens/privacy_policy_screen.dart`
- `albaqer_gemstone_flutter/lib/screens/terms_screen.dart`

**Dependencies:** None  
**Impact:** LOW - Legal compliance

---

## 🟢 PHASE 7: POLISH & OPTIMIZATION (Week 13-14)
**Goal:** UI/UX improvements and performance

### P2-9: UI/UX Improvements ⏱️ 3-4 days
**Priority:** MEDIUM - Better experience  
**Issues #25, #26, #27:** Loading states, empty states, responsive design

**Tasks:**
- [ ] Add consistent loading indicators
- [ ] Design empty state screens
- [ ] Improve responsive design for tablets
- [ ] Add skeleton loaders
- [ ] Improve error messages across app

**Files to Modify:**
- Multiple screen files

**Dependencies:** None  
**Impact:** MEDIUM - Professional appearance

---

### P2-10: Better Error Handling ⏱️ 2 days
**Priority:** MEDIUM - UX improvement  
**Issues #18, #19:** Generic errors, network handling

**Tasks:**
- [ ] Add specific error messages in Flutter
- [ ] Add offline mode indicators
- [ ] Implement retry mechanisms
- [ ] Add error boundary widgets
- [ ] Improve network error handling

**Files to Modify:**
- All service files

**Dependencies:** None  
**Impact:** MEDIUM - Better UX during errors

---

### P2-11: Chatbot Improvements ⏱️ 2-3 days
**Priority:** LOW - Enhancement  
**Issue #24:** Basic integration

**Tasks:**
- [ ] Add session persistence
- [ ] Improve error handling when server down
- [ ] Add in-app notifications for responses
- [ ] Add chat history persistence
- [ ] Improve chatbot UI

**Files to Modify:**
- `albaqer_gemstone_flutter/lib/screens/chatbot_screen.dart`

**Dependencies:** Chatbot server running  
**Impact:** LOW - Enhancement

---

## 🟢 PHASE 8: DOCUMENTATION & DEVOPS (Ongoing)
**Goal:** Developer experience and deployment

### P3-2: API Documentation ⏱️ 2-3 days
**Priority:** LOW - Developer experience  
**Issue #30:** No API docs

**Tasks:**
- [ ] Add Swagger/OpenAPI documentation
- [ ] Document all endpoints with examples
- [ ] Add Postman collection
- [ ] Create API usage guide

**Files to Create:**
- `albaqer_gemstone_backend/docs/swagger.yaml`

**Dependencies:** None  
**Impact:** LOW - Better developer onboarding

---

### P3-3: Setup Automation ⏱️ 2 days
**Priority:** LOW - DevOps  
**Issue #31:** Complex setup

**Tasks:**
- [ ] Create setup scripts
- [ ] Add Docker containers
- [ ] Create docker-compose.yml
- [ ] Automate database migrations
- [ ] Add CI/CD pipeline

**Files to Create:**
- `docker-compose.yml`
- `.github/workflows/ci.yml`

**Dependencies:** None  
**Impact:** LOW - Easier deployment

---

## 📈 Implementation Timeline Summary

### Month 1 (Weeks 1-4)
- **Week 1-2:** PHASE 1 - Critical Fixes (Addresses, Order Status, Stock)
- **Week 3-4:** PHASE 2 - Core Features (Reviews, Payment, Cart/Wishlist Sync)

### Month 2 (Weeks 5-8)
- **Week 5-6:** PHASE 3 - Role Features (Manager, Delivery)
- **Week 7-8:** PHASE 4 - Product Enhancements (Search, Categories, Analytics)

### Month 3 (Weeks 9-12)
- **Week 9-10:** PHASE 5 - UX Improvements (Tracking, Profile, Order History)
- **Week 11-12:** PHASE 6 - Security (Token Refresh, Validation, API Security)

### Month 4 (Weeks 13-14+)
- **Week 13-14:** PHASE 7 - Polish (UI/UX, Error Handling)
- **Ongoing:** PHASE 8 - Documentation & DevOps

---

## 🎯 Recommended Start Order

### ✅ PHASE 1 COMPLETED (Weeks 1-2)
1. ✅ **Dashboard Images Fix** - COMPLETED
2. ✅ **Address System Backend + Flutter UI** (P0-1) - COMPLETED
3. ✅ **Order Status Fix** (P0-2) - COMPLETED
4. ✅ **Stock Management** (P0-3) - COMPLETED
5. ✅ **Stock Display Bug Fixes** - COMPLETED
   - Fixed isAvailable boolean check blocking valid products
   - Implemented getAvailableStock() accounting for cart items
   - Added cache invalidation on checkout
   - Implemented auto-reload on screen resume
   - Added detailed stock error parsing

### 🟠 NEXT: PHASE 2 (Week 3-4)
6. 🟠 **Reviews System** (P1-1) - Next Priority
7. 🟠 **Payment Gateway Integration** (P1-2)
8. 🟠 **Cart Sync Backend** (P1-3)
9. 🟠 **Wishlist Sync Backend** (P1-4)

### Following Weeks
Continue with priority order: P1 → P2 → P3

---

## 📊 Effort Estimation

| Phase | Features | Total Effort | Priority |
|-------|----------|--------------|----------|
| Phase 1 | 4 features | 8-12 days | P0 ✅ COMPLETE |
| Phase 2 | 4 features | 12-16 days | P1 |
| Phase 3 | 2 features | 9-11 days | P1 |
| Phase 4 | 4 features | 12-16 days | P2 |
| Phase 5 | 3 features | 8-11 days | P1-P2 |
| Phase 6 | 4 features | 9-12 days | P1-P2 |
| Phase 7 | 3 features | 7-9 days | P2 |
| Phase 8 | 2 features | 4-5 days | P3 |
| **TOTAL** | **26 features** | **69-92 days** | (~3-4 months) |
| **COMPLETED** | **4 features** | **~10 days** | **Phase 1 Done** |

---

## 🚀 Quick Action Items (Next 48 Hours)

### ✅ ALL P0 CRITICAL FIXES COMPLETE!

**Completed This Week:**
1. ✅ Address Management System (P0-1)
2. ✅ Order Status Update Fix (P0-2)
3. ✅ Stock Management System (P0-3)
4. ✅ Stock Display & Cache Bug Fixes

**Next Actions:**
1. **Immediate:** Push all changes to GitHub (preserves major milestone)
2. **This Week:** Begin P1-1 Reviews System implementation
3. **Following Week:** P1-2 Payment Gateway Integration

---

## 📌 Notes

- **Payment Integration (P1-2)** is marked HIGH but requires 3rd party account setup
- **Gemstone Scan (P2-3)** requires ML expertise, may need external consultants
- **Testing time** not included in estimates - add 20-30% for QA
- **Database migrations** needed before implementing some features
- Consider **breaking changes** that might affect existing users

---

**Status Legend:**
- 🔴 Critical - Must fix immediately
- 🟠 High - Next sprint priority  
- 🟡 Medium - Future sprints
- 🟢 Low - Nice to have
- ✅ Complete
- 🏗️ In Progress
- ⏸️ Blocked
- ⏰ Scheduled
