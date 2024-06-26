// Dashboard.tsx
'use client';
import JobDurationChart from '../ChartJobDuration';
import * as React from 'react';
import { PageSection } from '@patternfly/react-core/dist/dynamic/components/Page';
import { Title } from '@patternfly/react-core/dist/dynamic/components/Title';
import { Card } from '@patternfly/react-core/dist/dynamic/components/Card';
import { CardBody } from '@patternfly/react-core/dist/dynamic/components/Card';
import { CardTitle } from '@patternfly/react-core/dist/dynamic/components/Card';
import JobStatusPieChart from '../ChartJobDistribution';

const Index: React.FunctionComponent = () => {
  return (
    <PageSection>
      <Title headingLevel="h1" size="lg">
        Dashboard
      </Title>
      <Card>
        {' '}
        <CardTitle>Job Status Distribution</CardTitle>
        <CardBody>
          <JobStatusPieChart />
        </CardBody>
      </Card>

      <Card>
        <CardTitle>Successful Job Durations</CardTitle>
        <CardBody>
          <JobDurationChart />
        </CardBody>
      </Card>
    </PageSection>
  );
};

export { Index };
