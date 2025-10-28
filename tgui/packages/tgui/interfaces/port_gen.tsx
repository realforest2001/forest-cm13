import type { BooleanLike } from 'common/react';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  is_on: BooleanLike;
  sheet_name: string;
  sheets: number;
  stack_percent: number;
  anchored: BooleanLike;
  connected: BooleanLike;
  ready_to_boot: BooleanLike;
  power_generated: number;
  power_output: number;
  power_available: number;
  heat: number;
};

export const port_gen = (props) => {
  const { act, data } = useBackend<Data>();
  const stack_percent = data.stack_percent;
  const stackPercentState =
    (stack_percent > 50 && 'good') ||
    (stack_percent > 15 && 'average') ||
    'bad';
  return (
    <Window width={450} height={340}>
      <Window.Content scrollable>
        {!data.anchored && <NoticeBox>Generator not anchored.</NoticeBox>}
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Power switch">
              <Button
                icon={data.is_on ? 'power-off' : 'times'}
                onClick={() => act('toggle_power')}
                disabled={!data.ready_to_boot}
              >
                {data.is_on ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label={`${data.sheet_name} sheets`}>
              <Box inline color={stackPercentState}>
                {data.sheets}
              </Box>
              {data.sheets >= 1 && (
                <Button
                  ml={1}
                  icon="eject"
                  disabled={data.is_on}
                  onClick={() => act('eject')}
                >
                  Eject
                </Button>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Current sheet level">
              <ProgressBar
                value={data.stack_percent / 100}
                ranges={{
                  good: [0.1, Infinity],
                  average: [0.01, 0.1],
                  bad: [-Infinity, 0.01],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Heat level">
              {data.heat < 100 ? (
                <Box inline color="good">
                  Nominal
                </Box>
              ) : data.heat < 200 ? (
                <Box inline color="average">
                  Caution
                </Box>
              ) : (
                <Box inline color="bad">
                  DANGER
                </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Output">
          <LabeledList>
            <LabeledList.Item label="Current output">
              {data.power_output}
            </LabeledList.Item>
            <LabeledList.Item label="Adjust output">
              <Button icon="minus" onClick={() => act('lower_power')}>
                {data.power_generated}
              </Button>
              <Button icon="plus" onClick={() => act('higher_power')}>
                {data.power_generated}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Power available">
              <Box inline color={!data.connected && 'bad'}>
                {data.connected ? data.power_available : 'Unconnected'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
