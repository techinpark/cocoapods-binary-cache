describe "PodCacheValidator" do
  describe "verify prebuilt vendor pods" do
    let(:pods) do
      {
        "A" => { :version => "0.0.5" },
        "B" => { :version => "0.0.5" },
        "C" => { :version => "0.0.5" }
      }
    end
    let(:pod_lockfile) { gen_lockfile(pods: pods) }
    let(:prebuilt_lockfile) { gen_lockfile(pods: pods) }
    before do
      validation_result = PodPrebuild::CacheValidator.new(pod_lockfile, prebuilt_lockfile).validate
      @missed = validation_result.missed
      @hit = validation_result.hit
    end

    context "all cache hits" do
      it "returns non missed, all hit" do
        expect(@missed).to be_empty
        expect(@hit).to eq(pods.keys.to_set)
      end
    end

    context "some cache miss due to outdated" do
      let(:pod_lockfile) { gen_lockfile(pods: pods.merge("A" => { :version => "0.0.1" })) }
      it "returns some missed, some hit" do
        expect(@missed).to eq(["A"].to_set)
        expect(@hit).to eq(pods.keys.to_set - ["A"])
      end
    end

    context "some cache miss due to not present" do
      let(:pod_lockfile) { gen_lockfile(pods: pods.merge("D" => { :version => "0.0.5" })) }
      it "returns some missed, some hit" do
        expect(@missed).to eq(["D"].to_set)
        expect(@hit).to eq(pods.keys.to_set)
      end
    end

    context "no cache due to no prebuilt_lockfile" do
      let(:prebuilt_lockfile) { nil }
      it "returns all missed" do
        expect(@missed).to eq(pods.keys.to_set)
        expect(@hit).to be_empty
      end
    end
  end
end
