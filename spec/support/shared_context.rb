module SharedContext
  def update(name, &block)
    define_method(name) do
      super().update(instance_eval(&block))
    end
  end

  def messages(&block)
    let(:message_sequence) do
      FakeActor::MessageSequence.new.tap do |sequence|
         sequence.instance_eval(&block)
      end
    end
  end

  # rubocop:disable MethodLength
  def setup_shared_context
    let(:env)              { double('env', config: config, subjects: [subject_a], mutations: mutations) }
    let(:job_a)            { Mutant::Runner::Job.new(index: 0, mutation: mutation_a)                    }
    let(:job_b)            { Mutant::Runner::Job.new(index: 1, mutation: mutation_b)                    }
    let(:job_a_result)     { Mutant::Runner::JobResult.new(job: job_a, result: mutation_a_result)       }
    let(:job_b_result)     { Mutant::Runner::JobResult.new(job: job_b, result: mutation_b_result)       }
    let(:mutations)        { [mutation_a, mutation_b]                                                   }
    let(:matchable_scopes) { double('matchable scopes', length: 10)                                     }
    let(:test_a)           { double('test a', identification: 'test-a')                                 }
    let(:test_b)           { double('test b', identification: 'test-b')                                 }
    let(:actor_names)      { []                                                                         }
    let(:message_sequence) { FakeActor::MessageSequence.new                                             }

    let(:config) do
      Mutant::Config::DEFAULT.update(
        actor_env: actor_env,
        jobs:      1,
        reporter:  Mutant::Reporter::Trace.new
      )
    end

    let(:actor_env) do
      FakeActor::Env.new(message_sequence, actor_names)
    end

    let(:subject_a) do
      double(
        'subject a',
        node:           s(:true),
        source:         'true',
        tests:          [test_a],
        identification: 'subject-a'
      )
    end

    before do
      allow(subject_a).to receive(:mutations).and_return([mutation_a, mutation_b])
    end

    let(:empty_status) do
      Mutant::Runner::Status.new(
        active_jobs: Set.new,
        env_result:  env_result.update(subject_results: [], runtime: 0.0),
        done:        false
      )
    end

    let(:status) do
      Mutant::Runner::Status.new(
        active_jobs: Set.new,
        env_result:  env_result,
        done:        true
      )
    end

    let(:env_result) do
      Mutant::Result::Env.new(
        env:             env,
        runtime:         4.0,
        subject_results: [subject_a_result]
      )
    end

    let(:mutation_a_node) { s(:false) }
    let(:mutation_b_node) { s(:nil)   }

    let(:mutation_b) { Mutant::Mutation::Evil.new(subject_a, mutation_b_node) }
    let(:mutation_a) { Mutant::Mutation::Evil.new(subject_a, mutation_a_node) }

    let(:mutation_a_result) do
      Mutant::Result::Mutation.new(
        index:       1,
        mutation:    mutation_a,
        test_result: mutation_a_test_result
      )
    end

    let(:mutation_b_result) do
      Mutant::Result::Mutation.new(
        index:       1,
        mutation:    mutation_a,
        test_result: mutation_b_test_result
      )
    end

    let(:mutation_a_test_result) do
      Mutant::Result::Test.new(
        tests:    [test_a],
        passed:   false,
        runtime:  1.0,
        output:  'mutation a test result output'
      )
    end

    let(:mutation_b_test_result) do
      Mutant::Result::Test.new(
        tests:    [test_a],
        passed:   false,
        runtime:  1.0,
        output:   'mutation b test result output'
      )
    end

    let(:subject_a_result) do
      Mutant::Result::Subject.new(
        subject:          subject_a,
        mutation_results: [mutation_a_result, mutation_b_result]
      )
    end

    let(:empty_subject_a_result) do
      subject_a_result.update(mutation_results: [])
    end

    let(:partial_subject_a_result) do
      subject_a_result.update(mutation_results: [mutation_a_result])
    end
  end
end
