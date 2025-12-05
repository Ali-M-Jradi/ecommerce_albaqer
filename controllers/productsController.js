const { supabase } = require("../supabaseClient");

// GET all products
const getAllProducts = async (req, res) => {
    try {
        const { data, error } = await supabase
            .from("products")
            .select(`
                *,
                categories (id, name, description),
                materials (id, name, purity, color),
                product_images (id, image_url)
            `);
        if (error) throw error;
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// GET product by ID
const getProductById = async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase
            .from("products")
            .select(`
                *,
                categories (id, name, description),
                materials (id, name, purity, color),
                product_images (id, image_url),
                reviews (id, user_id, rating, comment, created_at)
            `)
            .eq("id", id)
            .single();
        if (error) throw error;
        if (!data) return res.status(404).json({ error: "Product not found" });
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// CREATE product
const createProduct = async (req, res) => {
    try {
        const { name, description, price, size, category_id, material_id, stock } = req.body;
        const { data, error } = await supabase
            .from("products")
            .insert([{
                name,
                description,
                price,
                size,
                category_id,
                material_id,
                stock
            }])
            .select();
        if (error) throw error;
        res.status(201).json(data[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// UPDATE product
const updateProduct = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, description, price, size, category_id, material_id, stock } = req.body;
        const { data, error } = await supabase
            .from("products")
            .update({
                name,
                description,
                price,
                size,
                category_id,
                material_id,
                stock,
                updated_at: new Date()
            })
            .eq("id", id)
            .select();
        if (error) throw error;
        if (data.length === 0) return res.status(404).json({ error: "Product not found" });
        res.json(data[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// DELETE product
const deleteProduct = async (req, res) => {
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
};

module.exports = {
    getAllProducts,
    getProductById,
    createProduct,
    updateProduct,
    deleteProduct
};
