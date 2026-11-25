"""Rules of the state banner (no Qt, no ROS): pytest test/test_banner.py."""

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent / 'krabi_gui'))

from banner import banner, can_recalage, can_restart  # noqa: E402


@pytest.mark.parametrize('alive, state, inserted, errors, text, kind', [
    (False, 'ready', True, [], 'ROBOT DÉMARRE…', 'grey'),
    (True, '', True, [], 'ROBOT DÉMARRE…', 'grey'),
    (True, 'wait_tirette_in', False, [], 'TIRETTE EN ATTENTE', 'wait'),
    (True, 'wait_tirette_in: recalé (Départ)', False, ['a : b'],
     'TIRETTE EN ATTENTE — recalé (Départ)', 'wait'),
    (True, 'init', True, [], 'INITIALISATION…', 'busy'),
    (True, 'recalage: 2/3 wall Y_MIN 0.10', False, [],
     'RECALAGE EN COURS — 2/3 wall Y_MIN 0.10', 'busy'),
    (True, 'ready', True, [], 'ROBOT PRÊT', 'ready'),
    (True, 'ready: recalé (Départ)', True, [], 'ROBOT PRÊT — recalé (Départ)', 'ready'),
    (True, 'ready', False, [], 'TIRETTE EN ATTENTE', 'wait'),
    (True, 'ready', True, ['CAN : muet'], 'PAS PRÊT : CAN : muet', 'error'),
    (True, 'ready', True, ['CAN : muet', 'x : y'], 'PAS PRÊT : CAN : muet (+1)', 'error'),
    (True, 'recalage_failed: étape 2/3 wall Y_MIN 0.10 : pas de contact', True, [],
     'PAS PRÊT : étape 2/3 wall Y_MIN 0.10 : pas de contact', 'error'),
    (True, 'match', False, ['a : b'], 'MATCH EN COURS', 'match'),
    (True, 'end', False, [], 'MATCH TERMINÉ — RESTART COLOR', 'end'),
])
def test_banner(alive, state, inserted, errors, text, kind):
    assert banner(alive, state, inserted, errors) == {'text': text, 'kind': kind}


@pytest.mark.parametrize('state, allowed', [
    ('wait_tirette_in', True), ('wait_tirette_in: recalé (Départ)', True), ('ready', True),
    ('recalage_failed: x', True), ('recalage: préparation', False), ('init', False),
    ('match', False), ('end', False), ('', False),
])
def test_can_recalage(state, allowed):
    assert can_recalage(True, state) == allowed
    assert not can_recalage(False, state)


def test_restart_is_forbidden_only_during_a_match():
    assert not can_restart(True, 'match')
    assert can_restart(False, 'match')  # crashed
    assert can_restart(True, 'end')
    assert can_restart(True, 'recalage: 1/3 wall X_MIN 0.10')
