//Big shoutout/thank you to Felix- D3Ulo for writing the infusion handler code for me!

//Speed Bonus Handler
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





//Damage Handler
function __demonic_atk_runtime() {
    if (global[$ "__demonic_atk"] == undefined) {
        global.__demonic_atk = { registered_hooks: undefined };
    }
    return global.__demonic_atk;
}

function demonic_atk_gather(_player) {
    var _result = { pct: 0, flat: 0 };
    var _armor = _player.armor;
    var _count = _armor.size();
    for (var _i = 0; _i < _count; _i++) {
        var _item = _armor.slot(_i).item;
        if (_item == undefined) continue;
        var _inf = _item.infusion;
        if (_inf == undefined) continue;
        var _p = _item.get_infusion_modifier(_inf, "atk_percent");
        var _f = _item.get_infusion_modifier(_inf, "atk_flat");
        if (is_real(_p)) _result.pct += _p;
        if (is_real(_f)) _result.flat += _f;
    }
    return _result;
}

// FILTER (value, ctx): value = obj_damage_tarball, ctx = obj_damage_receiver.
function demonic_atk_filter(_value, _ctx) {
    if (_value == undefined || !instance_exists(_value)) return undefined; // earlier mod dropped it, I just copied this from the md site, you prolly want to remove this since you always want this to apply even if someone else modified I think
    if (_value.target != CombatTarget.Enemy) return undefined;             // only player outgoing hits
    if (!instance_exists(obj_ari)) return undefined;                       // no loaded world / no player

    var hardcap = 9999999;
    if ( _value.damage > 10000000) _value.damage = hardcap; //it's janky af but it works so what the hell...
    if ( _value.damage > 9999998) return undefined;   //attempt to put a damage cap to prevent an infinite loop from occuring, crashing the game...

    var _b = demonic_atk_gather(ARI);
    _value.damage = _value.damage * (1 + _b.pct / 100) + _b.flat;          // The _value here is the "damage" object so to know which fields you can edit (in this the case the damage field) you need to actually look for the relevant GML file in this case it's in assets\gml\objects\Combat 
    return undefined;                                                      // keeping the (mutated) tarball
}

function demonic_atk_register_callbacks() {
    var _rt = __demonic_atk_runtime();
    if (_rt.registered_hooks != undefined) return;
    _rt.registered_hooks = true;

    mmapi_filter("combat.damage", demonic_atk_filter);
}

mmapi_mod_declare("demonic_atk", "1.0.0");
demonic_atk_register_callbacks();