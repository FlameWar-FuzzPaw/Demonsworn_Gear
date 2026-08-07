#macro CUSTOM_CRAFTING_FRAMEWORK_MOD_NAME "custom_crafting_framework"

function __custom_crafting_framework_runtime() {
    if (global[$ "__custom_crafting_framework"] == undefined) {
        global.__custom_crafting_framework = { registered: undefined, ui_cache: {} };
    }
    return global.__custom_crafting_framework;
}

function custom_crafting_is_builtin_menu(menu_val) {
    return menu_val == "kitchen"
        || menu_val == "woodcrafting"
        || menu_val == "forge"
        || menu_val == "mill";
}

function custom_crafting_list_has_item(list, item_id) {
    for (var i = 0, n = list.count(); i < n; i++) {
        if (list.get(i).item_id == item_id) return true;
    }
    return false;
}

function custom_crafting_build_ui(key) {
    var data = load_crafting_ui_data(key);
    var cats = data.get("categories");

    var all_tags = List();
    for (var i = 0; i < cats.count(); i++) {
        var subs = cats.get(i).sub_categories;
        for (var j = 0; j < subs.count(); j++) {
            var t = subs.get(j)[$ "tags"];
            if (t != undefined) all_tags.copy_from(t);
        }
    }

    var total = array_length(ITEM_PROTOTYPES);
    for (var i = 0; i < cats.count(); i++) {
        var subs = cats.get(i).sub_categories;
        for (var j = 0; j < subs.count(); j++) {
            var sub = subs.get(j);
            var match_tags = (sub[$ "tags"] != undefined && sub.tags.count() > 0) ? sub.tags : all_tags;
            if (match_tags.count() == 0) continue;
            for (var k = 0; k < total; k++) {
                var proto = ITEM_PROTOTYPES[k];
                if (proto == undefined || proto.recipe == undefined || proto[$ "tags"] == undefined) continue;
                if (!proto.tags.any(function(t, accept) { return accept.contains(t); }, match_tags)) continue;
                if (custom_crafting_list_has_item(sub.items, k)) continue;
                sub.items.push(new LiveItem(k));
            }
        }
    }
    return data;
}

function custom_crafting_ui_data(key) {
    var _s = __custom_crafting_framework_runtime();
    var cached = _s.ui_cache[$ key];
    if (cached == false) return undefined;
    if (cached != undefined) return cached;

    var data = undefined;
    try {
        data = custom_crafting_build_ui(key);
    } catch (_) {
        data = undefined;
    }
    _s.ui_cache[$ key] = (data == undefined) ? false : data;
    return data;
}

function custom_crafting_on_interact(node) {
    if (node == undefined) return undefined;

    var proto = node[$ "prototype"];
    if (proto == undefined) return undefined;

    var im = proto[$ "interact_menu"];
    if (im == undefined) return undefined;

    var menu_val = im[$ "menu"];
    if (menu_val == undefined) return undefined;
    if (custom_crafting_is_builtin_menu(menu_val)) return undefined; // engine handles these

    var ui = custom_crafting_ui_data(menu_val);
    if (ui == undefined) return undefined; // not a custom crafting station -> defer

    var xx = node.renderer.x + im.ari_offset.x;
    var yy = node.renderer.y + im.ari_offset.y;

    var menu = spawn_crafting_menu(ui, xx, yy, node.object_id);
    menu.object_coordinates.x = node.renderer.x;
    menu.object_coordinates.y = node.renderer.y;

    return true;
}

function custom_crafting_install() {
    if (!instance_exists(obj_ari)) return;
    for (var k = 0, n = array_length(ITEM_PROTOTYPES); k < n; k++) {
        var proto = ITEM_PROTOTYPES[k];
        if (proto == undefined || proto.recipe == undefined) continue;
        if (!proto.recipe.is_default) continue;
        if (k >= array_length(ARI.recipe_unlocks) || ARI.recipe_unlocks[k] != true) {
            ARI.recipe_unlocks[k] = true;
            ARI.recipes_created[k] = false;
        }
    }
}

function custom_crafting_register_callbacks() {
    var _s = __custom_crafting_framework_runtime();
    if (_s.registered != undefined) return;
    _s.registered = true;
    mmapi_override("object.interact", custom_crafting_on_interact);
    mmapi_register(custom_crafting_install);
}

mmapi_mod_declare(CUSTOM_CRAFTING_FRAMEWORK_MOD_NAME, "1.0.0");
mmapi_log_info(CUSTOM_CRAFTING_FRAMEWORK_MOD_NAME, "Custom Crafting Framework starting.");
custom_crafting_register_callbacks();
