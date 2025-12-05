const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const { supabase } = require("./supabaseClient");

dotenv.config();
const app = express();

app.use(cors());
app.use(express.json());

// Test route
app.get("/", (req, res) => {
    res.send("Backend is running with Supabase...");
});

// ============= PRODUCTS =============

// Products - GET all
app.get("/products", async (req, res) => {
    try {
        const { data, error } = await supabase.from("products").select("*");
        if (error) throw error;
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Products - GET by ID
app.get("/products/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from("products")
            .select("*")
            .eq("id", id)
            .single();
        if (error) throw error;
        if (!data) return res.status(404).json({ error: "Product not found" });
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Products - CREATE
app.post("/products", async (req, res) => {
    try {
        const { name, description, price, size, category_id, material_id, stock } = req.body;
        const { data, error } = await supabase
            .from("products")
            .insert([{ name, description, price, size, category_id, material_id, stock }])
            .select();
        if (error) throw error;
        res.status(201).json(data[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Products - UPDATE
app.put("/products/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const { name, description, price, size, category_id, material_id, stock } = req.body;
        const { data, error } = await supabase
            .from("products")
            .update({ name, description, price, size, category_id, material_id, stock })
            .eq("id", id)
            .select();
        if (error) throw error;
        if (data.length === 0) return res.status(404).json({ error: "Product not found" });
        res.json(data[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Products - DELETE
app.delete("/products/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from("products")
            .delete()
            .eq("id", id)
            .select();
        if (error) throw error;
        if (data.length === 0) return res.status(404).json({ error: "Product not found" });
        res.json({ message: "Product deleted", product: data[0] });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============= CATEGORIES =============

// Categories - GET all
app.get("/categories", async (req, res) => {
    try {
        const { data, error } = await supabase.from("categories").select("*");
        if (error) throw error;
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Categories - GET by ID
app.get("/categories/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from("categories")
            .select("*")
            .eq("id", id)
            .single();
        if (error) throw error;
        if (!data) return res.status(404).json({ error: "Category not found" });
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Categories - CREATE
app.post("/categories", async (req, res) => {
    try {
        const { name, description } = req.body;
        const { data, error } = await supabase
            .from("categories")
            .insert([{ name, description }])
            .select();
        if (error) throw error;
        res.status(201).json(data[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============= ORDERS =============

// Orders - GET all
app.get("/orders", async (req, res) => {
    try {
        const { data, error } = await supabase.from("orders").select("*");
        if (error) throw error;
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Orders - GET by ID
app.get("/orders/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from("orders")
            .select("*")
            .eq("id", id)
            .single();
        if (error) throw error;
        if (!data) return res.status(404).json({ error: "Order not found" });
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Orders - CREATE
app.post("/orders", async (req, res) => {
    try {
        const { user_id, total, status } = req.body;
        const { data, error } = await supabase
            .from("orders")
            .insert([{ user_id, total, status: status || "pending" }])
            .select();
        if (error) throw error;
        res.status(201).json(data[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Orders - UPDATE status
app.put("/orders/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        const { data, error } = await supabase
            .from("orders")
            .update({ status })
            .eq("id", id)
            .select();
        if (error) throw error;
        if (data.length === 0) return res.status(404).json({ error: "Order not found" });
        res.json(data[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============= USERS =============

// Users - GET all
app.get("/users", async (req, res) => {
    try {
        const { data, error } = await supabase
            .from("users")
            .select("id, full_name, email, phone, role, created_at");
        if (error) throw error;
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Users - GET by ID
app.get("/users/:id", async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from("users")
            .select("id, full_name, email, phone, role, created_at")
            .eq("id", id)
            .single();
        if (error) throw error;
        if (!data) return res.status(404).json({ error: "User not found" });
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Users - CREATE (Register)
app.post("/users", async (req, res) => {
    try {
        const { full_name, email, phone, password_hash, role } = req.body;
        const { data, error } = await supabase
            .from("users")
            .insert([{ full_name, email, phone, password_hash, role: role || "customer" }])
            .select("id, full_name, email, phone, role, created_at");
        if (error) throw error;
        res.status(201).json(data[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============= ORDER ITEMS =============

// Order Items - GET by Order ID
app.get("/orders/:orderId/items", async (req, res) => {
    try {
        const { orderId } = req.params;
        const { data, error } = await supabase
            .from("order_items")
            .select("*")
            .eq("order_id", orderId);
        if (error) throw error;
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Order Items - CREATE
app.post("/order-items", async (req, res) => {
    try {
        const { order_id, product_id, quantity, price } = req.body;
        const { data, error } = await supabase
            .from("order_items")
            .insert([{ order_id, product_id, quantity, price }])
            .select();
        if (error) throw error;
        res.status(201).json(data[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
