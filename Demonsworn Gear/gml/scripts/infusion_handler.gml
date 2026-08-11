function __demonic_speed_runtime() {
    if (global[$ "__demonic_speed"] == undefined) {
        global.__demonic_speed = { registered_hooks: undefined };
    }
    return global.__demonic_speed;
}

function demonic_speed_gather(_player) {
    var _result = { pct: 0, flat: 0 };
    var _armor = _player.armor;
    var _count = _armor.size();
    for (var _i = 0; _i < _count; _i++) {
        var _item = _armor.slot(_i).item;
        if (_item == undefined) continue;
        var _inf = _item.infusion;
        if (_inf == undefined) continue;
        var _p = _item.get_infusion_modifier(_inf, "speed_percent");
        var _f = _item.get_infusion_modifier(_inf, "speed_flat");
        if (is_real(_p)) _result.pct += _p;
        if (is_real(_f)) _result.flat += _f;
    }
    return _result;
}

function demonic_speed_apply(_value, _player) {
    var _b = demonic_speed_gather(_player);
    return _value * (1 + _b.pct / 100) + _b.flat;
}

function demonic_speed_move_speed(_value, _ctx) {
    if (_value == undefined) return undefined;
    if (_ctx.on_mount) return undefined;
    if (!_ctx.player.run_toggle) return undefined;
    return demonic_speed_apply(_value, _ctx.player);
}

function demonic_speed_swim_speed(_value, _ctx) {
    if (_value == undefined) return undefined;
    if (!_ctx.player.run_toggle) return undefined;
    return demonic_speed_apply(_value, _ctx.player);
}

function demonic_speed_register_callbacks() {
    var _rt = __demonic_speed_runtime();
    if (_rt.registered_hooks != undefined) return;
    _rt.registered_hooks = true;

    mmapi_filter("player.move_speed", demonic_speed_move_speed);
    mmapi_filter("player.swim_speed", demonic_speed_swim_speed);
}

mmapi_mod_declare("demonic_speed", "1.0.0");
demonic_speed_register_callbacks();