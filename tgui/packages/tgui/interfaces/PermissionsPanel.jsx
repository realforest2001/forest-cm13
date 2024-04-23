import { useBackend, useLocalState } from '../backend';
import { Button, Stack, Section, Flex, Dropdown } from '../components';
import { Window } from '../layouts';

const PAGES = {
  'Panel': () => PlayerList,
  'Update': () => StatusUpdate,
};

export const PermissionsPanel = (props, context) => {
  const { data } = useBackend(context);
  const { current_menu } = data;
  const PageComponent = PAGES[current_menu]();

  return (
    <Window theme={'crtyellow'} width={990} height={750}>
      <Window.Content scrollable>
        <PageComponent />
      </Window.Content>
    </Window>
  );
};

const PlayerList = (props, context) => {
  const { data, act } = useBackend(context);
  const { staff_list } = data;

  return (
    <Section>
      <Flex align="center" grow>
        <Flex.Item mr="1rem">
          <Button
            icon="clipboard"
            content="Search"
            tooltip="Add new player, or find an existing one."
            onClick={() => act('add_player')}
          />
        </Flex.Item>
        <Flex.Item>
          <Button
            icon="rotate-right"
            textAlign="center"
            tooltip="Refresh Data"
            onClick={() => act('refresh_data')}
          />
        </Flex.Item>
        <Flex.Item width="80%">
          <h1 align="center">Permissions Panel</h1>
        </Flex.Item>
      </Flex>
      {!!staff_list.length && (
        <Flex
          className="candystripe"
          p=".75rem"
          align="center"
          fontSize="1.25rem">
          <Flex.Item bold width="15%" mr="1rem">
            CKey
          </Flex.Item>
          <Flex.Item bold width="10%" mr="1rem">
            Title
          </Flex.Item>
          <Flex.Item width="75%" bold>
            Status
          </Flex.Item>
        </Flex>
      )}
      {staff_list.map((record, i) => {
        return (
          <Flex key={i} className="candystripe" p=".75rem" align="center">
            <Flex.Item bold width="15%" mr="1rem">
              <Button
                content={record.ckey}
                icon="pen"
                tooltip="Edit Permissions"
                onClick={() => act('select_player', { player: record.ckey })}
              />
            </Flex.Item>
            <Flex.Item bold width="10%" mr="1rem">
              {record.title}
            </Flex.Item>
            <Flex.Item width="75%">{record.status}</Flex.Item>
          </Flex>
        );
      })}
    </Section>
  );
};

const StatusUpdate = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    admin_flags,
    dev_flags,
    event_flags,
    misc_flags,
    manager_flags,
    viewed_player,
    user_rights,
    target_rights,
    new_rights,
    staff_presets,
  } = data;

  const [selectedPreset, setPreset] = useLocalState(
    'selected_preset',
    Object.keys(staff_presets)[0]
  );

  return (
    <Section fill>
      <Flex align="center">
        <Flex.Item>
          <Button
            icon="arrow-left"
            px="2rem"
            textAlign="center"
            tooltip="Go back"
            onClick={() => act('go_back')}
          />
        </Flex.Item>
        <Flex.Item width="80%">
          <h1 align="center">Permissions for: {viewed_player.ckey}</h1>
        </Flex.Item>
      </Flex>
      <h2 align="center">Title: {viewed_player.title}</h2>
      <Section title="Administration">
        <Stack align="right" grow={1}>
          {admin_flags.map((bit, i) => {
            const isGranted = target_rights && target_rights & bit.bitflag;
            return (
              <Button
                key={i}
                width="100%"
                height="100%"
                color={isGranted ? 'purple' : 'blue'}
                tooltip={isGranted ? 'Granted' : 'Not Granted'}
                content={bit.name}
              />
            );
          })}
        </Stack>
        <Stack align="right" grow={1}>
          {admin_flags.map((bit, i) => {
            const new_state = new_rights && new_rights & bit.bitflag;
            const editable = user_rights && bit.permission & user_rights;
            return (
              <Button.Checkbox
                key={i}
                width="100%"
                height="100%"
                checked={new_state}
                color={new_state ? 'good' : 'bad'}
                content={bit.name}
                disabled={!editable}
                onClick={() =>
                  act('update_number', {
                    'perm_flag': !new_state
                      ? new_rights | bit.bitflag
                      : new_rights & ~bit.bitflag,
                  })
                }
              />
            );
          })}
        </Stack>
      </Section>
      <Section title="Development">
        <Stack align="right" grow={1}>
          {dev_flags.map((bit, i) => {
            const isGranted = target_rights && target_rights & bit.bitflag;
            return (
              <Button
                key={i}
                width="100%"
                height="100%"
                color={isGranted ? 'purple' : 'blue'}
                tooltip={isGranted ? 'Granted' : 'Not Granted'}
                content={bit.name}
              />
            );
          })}
        </Stack>
        <Stack align="right" grow={1}>
          {dev_flags.map((bit, i) => {
            const new_state = new_rights && new_rights & bit.bitflag;
            const editable = user_rights && bit.permission & user_rights;
            return (
              <Button.Checkbox
                key={i}
                width="100%"
                height="100%"
                checked={new_state}
                color={new_state ? 'good' : 'bad'}
                content={bit.name}
                disabled={!editable}
                onClick={() =>
                  act('update_number', {
                    'perm_flag': !new_state
                      ? new_rights | bit.bitflag
                      : new_rights & ~bit.bitflag,
                  })
                }
              />
            );
          })}
        </Stack>
      </Section>
      <Section title="Event">
        <Stack align="right" grow={1}>
          {event_flags.map((bit, i) => {
            const isGranted = target_rights && target_rights & bit.bitflag;
            return (
              <Button
                key={i}
                width="100%"
                height="100%"
                color={isGranted ? 'purple' : 'blue'}
                tooltip={isGranted ? 'Granted' : 'Not Granted'}
                content={bit.name}
              />
            );
          })}
        </Stack>
        <Stack align="right" grow={1}>
          {event_flags.map((bit, i) => {
            const new_state = new_rights && new_rights & bit.bitflag;
            const editable = user_rights && bit.permission & user_rights;
            return (
              <Button.Checkbox
                key={i}
                width="100%"
                height="100%"
                checked={new_state}
                color={new_state ? 'good' : 'bad'}
                content={bit.name}
                disabled={!editable}
                onClick={() =>
                  act('update_number', {
                    'perm_flag': !new_state
                      ? new_rights | bit.bitflag
                      : new_rights & ~bit.bitflag,
                  })
                }
              />
            );
          })}
        </Stack>
      </Section>
      <Section title="Misc">
        <Stack align="right" grow={1}>
          {misc_flags.map((bit, i) => {
            const isGranted = target_rights && target_rights & bit.bitflag;
            return (
              <Button
                key={i}
                width="100%"
                height="100%"
                color={isGranted ? 'purple' : 'blue'}
                tooltip={isGranted ? 'Granted' : 'Not Granted'}
                content={bit.name}
              />
            );
          })}
        </Stack>
        <Stack align="right" grow={1}>
          {misc_flags.map((bit, i) => {
            const new_state = new_rights && new_rights & bit.bitflag;
            const editable = user_rights && bit.permission & user_rights;
            return (
              <Button.Checkbox
                key={i}
                width="100%"
                height="100%"
                checked={new_state}
                color={new_state ? 'good' : 'bad'}
                content={bit.name}
                disabled={!editable}
                onClick={() =>
                  act('update_number', {
                    'perm_flag': !new_state
                      ? new_rights | bit.bitflag
                      : new_rights & ~bit.bitflag,
                  })
                }
              />
            );
          })}
        </Stack>
      </Section>
      <Section title="Management">
        <Stack align="right" grow={1}>
          {manager_flags.map((bit, i) => {
            const isGranted = target_rights && target_rights & bit.bitflag;
            return (
              <Button
                key={i}
                width="100%"
                height="100%"
                color={isGranted ? 'purple' : 'blue'}
                tooltip={isGranted ? 'Granted' : 'Not Granted'}
                content={bit.name}
              />
            );
          })}
        </Stack>
        <Stack align="right" grow={1}>
          {manager_flags.map((bit, i) => {
            const new_state = new_rights && new_rights & bit.bitflag;
            const editable = user_rights && bit.permission & user_rights;
            return (
              <Button.Checkbox
                key={i}
                width="100%"
                height="100%"
                checked={new_state}
                color={new_state ? 'good' : 'bad'}
                content={bit.name}
                disabled={!editable}
                onClick={() =>
                  act('update_number', {
                    'perm_flag': !new_state
                      ? new_rights | bit.bitflag
                      : new_rights & ~bit.bitflag,
                  })
                }
              />
            );
          })}
        </Stack>
      </Section>
      <Flex align="center">
        <Button
          icon="check"
          width="100%"
          textAlign="center"
          content="Update Permissions"
          tooltip="Update Permissions"
          onClick={() => act('update_perms', { 'player': viewed_player.ckey })}
        />
      </Flex>
      <Flex align="center">
        <Button
          icon="stamp"
          width="50%"
          textAlign="center"
          content="Apply Preset"
          tooltip="Apply Preset"
          onClick={() =>
            act('apply_preset', {
              'preset': staff_presets[selectedPreset],
              'title': selectedPreset,
            })
          }
        />

        <Dropdown
          color="blue"
          tooltip="Permissions Preset"
          selected={selectedPreset}
          options={Object.keys(staff_presets)}
          onSelected={(value) => setPreset(value)}
        />
      </Flex>
    </Section>
  );
};
