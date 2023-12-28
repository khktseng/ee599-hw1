#=========================================================================
# lab1-imul Subpackage
#=========================================================================

lab1_imul_deps = vc

lab1_imul_srcs = \
  lab1-imul-msgs.v \
  lab1-imul-IntMulFL.v \
  lab1-imul-IntMulBase.v \
  lab1-imul-IntMulAlt.v \
  lab1-imul-IntMulAlt-Data.v \
  lab1-imul-IntMulAlt-Ctrl.v \
  lab1-imul-test-harness.v \
  lab1-imul-sim-harness.v \
  lab1-imul-PriorityEncoder.v \
  lab1-imul-swap_av.v \

lab1_imul_test_srcs = \
  lab1-imul-msgs.t.v \
  lab1-imul-IntMulFL.t.v \
  lab1-imul-IntMulBase.t.v \
  lab1-imul-IntMulAlt.t.v \

lab1_imul_sim_srcs = \
  lab1-imul-sim-base.v \
  lab1-imul-sim-alt.v \

# You will need to add a .py.v file to the lab1_imul_pyv_srcs make
# variable for each random dataset you generate using the Python script.

lab1_imul_pyv_srcs = \
  lab1-imul-gen-input_small.py.v \
  lab1-imul-gen-input_spn.py.v \
  lab1-imul-gen-input_snp.py.v \
  lab1-imul-gen-input_snn.py.v \
  lab1-imul-gen-input_lpp.py.v \
  lab1-imul-gen-input_lpn.py.v \
  lab1-imul-gen-input_lnp.py.v \
  lab1-imul-gen-input_lnn.py.v \
  lab1-imul-gen-input_low-mask-a.py.v \
  lab1-imul-gen-input_low-mask-b.py.v \
  lab1-imul-gen-input_low-mask.py.v \
  lab1-imul-gen-input_mid-mask-a.py.v \
  lab1-imul-gen-input_mid-mask-b.py.v \
  lab1-imul-gen-input_mid-mask.py.v \
  lab1-imul-gen-input_sparse-a.py.v \
  lab1-imul-gen-input_sparse-b.py.v \
  lab1-imul-gen-input_sparse.py.v \
  lab1-imul-gen-input_dense-a.py.v \
  lab1-imul-gen-input_dense-b.py.v \
  lab1-imul-gen-input_dense.py.v \
  lab1-imul-gen-input_density-0.py.v \
  lab1-imul-gen-input_density-1.py.v \
  lab1-imul-gen-input_density-2.py.v \
  lab1-imul-gen-input_density-3.py.v \
  lab1-imul-gen-input_density-4.py.v \
  lab1-imul-gen-input_density-5.py.v \
  lab1-imul-gen-input_density-6.py.v \
  lab1-imul-gen-input_density-7.py.v \
  lab1-imul-gen-input_density-8.py.v \
  lab1-imul-gen-input_density-9.py.v \
  lab1-imul-gen-input_density-10.py.v \
  lab1-imul-gen-input_uniform.py.v \


#-------------------------------------------------------------------------
# Evaluation
#-------------------------------------------------------------------------

# List of implementations and inputs to evaluate

lab1_imul_eval_impls  = base alt

# You will need to add the names of your additional datasets to the
# lab1_imul_eval_inputs make variable.

lab1_imul_eval_inputs = \
  small   \
  spn     \
  snp     \
  snn     \
  lpp     \
  lpn     \
  lnp     \
  lnn     \
  low-mask-a \
  low-mask-b \
  low-mask   \
  mid-mask-a \
  mid-mask-b \
  mid-mask   \
  sparse-a  \
  sparse-b  \
  sparse  \
  dense-a \
  dense-b \
  dense   \
  density-0\
  density-1\
  density-2\
  density-3\
  density-4\
  density-5\
  density-6\
  density-7\
  density-8\
  density-9\
  density-10\
  uniform \

# Template used to create rules for each impl/input pair

define lab1_imul_eval_template

lab1_imul_eval_outs += lab1-imul-sim-$(1)-$(2).out

lab1-imul-sim-$(1)-$(2).out : lab1-imul-sim-$(1)
	./$$< +input=$(2) +stats | tee $$@

endef

# Call template for each impl/input pair

$(foreach impl,$(lab1_imul_eval_impls), \
  $(foreach dataset,$(lab1_imul_eval_inputs), \
    $(eval $(call lab1_imul_eval_template,$(impl),$(dataset)))))

# Grep all evaluation results

lab1-imul-eval : $(lab1_imul_eval_outs)
	@echo ""
	@grep avg_num_cycles_per_imul $^ | column -s ":=" -t
	@echo ""

#-------------------------------------------------------------------------
# Rules to generate harness
#-------------------------------------------------------------------------

lab1-imul-harness :
	$(scripts_dir)/gen-harness --verbose \
    ece4750-lab1-imul \
    $(src_dir) \
    $(src_dir)/lab1-imul/lab1-imul-gen-harness-cfg

.PHONY: lab1-imul-harness

lab1_imul_junk += ece4750-lab1-imul ece4750-lab1-imul.tar.gz

