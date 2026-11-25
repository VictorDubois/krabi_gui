"""Banner shown on every page: what the robot is doing, and whether it is ready.

No Qt and no ROS here, so that the rules can be tested alone (test/test_banner.py).
"""

# Pre-match states in which the robot accepts a recalage (see goal_strategy, pre_match_state)
_IDLE_STATES = ('wait_tirette_in', 'ready', 'recalage_failed')


def split_state(raw: str) -> tuple[str, str]:
    """'recalage: 2/3 wall Y_MIN 0.10' -> ('recalage', '2/3 wall Y_MIN 0.10')."""
    state, _, detail = raw.partition(':')
    return state.strip(), detail.strip()


def banner(alive: bool, raw_state: str, tirette_inserted: bool, errors: list[str]) -> dict:
    """Return {'text', 'kind'}; kind: grey, wait (yellow, blinking), busy, ready, error, match, end.

    alive: the robot published its state recently, and is not being restarted.
    errors: ROS diagnostics in error, "name : message".
    """
    state, detail = split_state(raw_state)
    suffix = f' — {detail}' if detail else ''

    if not alive or not state:
        return {'text': 'ROBOT DÉMARRE…', 'kind': 'grey'}
    if state == 'match':
        return {'text': 'MATCH EN COURS', 'kind': 'match'}
    if state == 'end':
        return {'text': 'MATCH TERMINÉ — RESTART COLOR', 'kind': 'end'}
    if state == 'init':
        return {'text': 'INITIALISATION…', 'kind': 'busy'}
    if state == 'recalage':
        return {'text': 'RECALAGE EN COURS' + suffix, 'kind': 'busy'}
    if state == 'recalage_failed':
        return {'text': 'PAS PRÊT : ' + (detail or 'recalage échoué'), 'kind': 'error'}
    if state == 'wait_tirette_in' or (state == 'ready' and not tirette_inserted):
        return {'text': 'TIRETTE EN ATTENTE' + suffix, 'kind': 'wait'}
    if state == 'ready':
        if errors:
            more = f' (+{len(errors) - 1})' if len(errors) > 1 else ''
            return {'text': 'PAS PRÊT : ' + errors[0] + more, 'kind': 'error'}
        return {'text': 'ROBOT PRÊT' + suffix, 'kind': 'ready'}
    return {'text': raw_state, 'kind': 'grey'}


def can_recalage(alive: bool, raw_state: str) -> bool:
    """Allow a recalage with or without the tirette, not during an action, init or match."""
    return alive and split_state(raw_state)[0] in _IDLE_STATES


def can_restart(alive: bool, raw_state: str) -> bool:
    """Forbid restarting the robot during a match, unless it is silent (crashed)."""
    return not (alive and split_state(raw_state)[0] == 'match')
