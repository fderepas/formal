// Lean compiler output
// Module: Gcd
// Imports: public import Init public meta import Init
#include <lean/lean.h>
#if defined(__clang__)
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wunused-label"
#elif defined(__GNUC__) && !defined(__CLANG__)
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wunused-label"
#pragma GCC diagnostic ignored "-Wunused-but-set-variable"
#endif
#ifdef __cplusplus
extern "C" {
#endif
uint8_t lean_nat_dec_eq(lean_object*, lean_object*);
lean_object* lean_nat_mod(lean_object*, lean_object*);
lean_object* l_Nat_reprFast(lean_object*);
lean_object* lean_string_append(lean_object*, lean_object*);
lean_object* lean_string_push(lean_object*, uint32_t);
lean_object* lean_get_stdout();
LEAN_EXPORT lean_object* lean_myGcd(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_IO_print___at___00IO_println___at___00main_spec__0_spec__0(lean_object*);
LEAN_EXPORT lean_object* l_IO_print___at___00IO_println___at___00main_spec__0_spec__0___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* l_IO_println___at___00main_spec__0(lean_object*);
LEAN_EXPORT lean_object* l_IO_println___at___00main_spec__0___boxed(lean_object*, lean_object*);
static const lean_string_object l_main___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 18, .m_capacity = 18, .m_length = 17, .m_data = "gcd(252, 105)  = "};
static const lean_object* l_main___closed__0 = (const lean_object*)&l_main___closed__0_value;
static lean_once_cell_t l_main___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* l_main___closed__1;
static lean_once_cell_t l_main___closed__2_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* l_main___closed__2;
static lean_once_cell_t l_main___closed__3_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* l_main___closed__3;
static const lean_string_object l_main___closed__4_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 18, .m_capacity = 18, .m_length = 17, .m_data = "gcd(1071, 462) = "};
static const lean_object* l_main___closed__4 = (const lean_object*)&l_main___closed__4_value;
static lean_once_cell_t l_main___closed__5_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* l_main___closed__5;
static lean_once_cell_t l_main___closed__6_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* l_main___closed__6;
static lean_once_cell_t l_main___closed__7_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* l_main___closed__7;
LEAN_EXPORT lean_object* _lean_main();
LEAN_EXPORT lean_object* l_main___boxed(lean_object*);
LEAN_EXPORT lean_object* lean_myGcd(lean_object* v_a_1_, lean_object* v_b_2_){
_start:
{
    lean_object* v___x_3_; uint8_t v___x_4_; 
    v___x_3_ = lean_unsigned_to_nat(0u);
    v___x_4_ = lean_nat_dec_eq(v_b_2_, v___x_3_);
    if (v___x_4_ == 0)
        {
            lean_object* v___x_5_; 
            v___x_5_ = lean_nat_mod(v_a_1_, v_b_2_);
            lean_dec(v_a_1_);
            v_a_1_ = v_b_2_;
            v_b_2_ = v___x_5_;
            goto _start;
        }
    else
        {
            lean_dec(v_b_2_);
            return v_a_1_;
        }
 }
}
    LEAN_EXPORT lean_object* l_IO_print___at___00IO_println___at___00main_spec__0_spec__0(lean_object* v_s_7_){
    _start:
        {
            lean_object* v___x_9_; lean_object* v_putStr_10_; lean_object* v___x_11_; 
            v___x_9_ = lean_get_stdout();
            v_putStr_10_ = lean_ctor_get(v___x_9_, 4);
            lean_inc_ref(v_putStr_10_);
            lean_dec_ref(v___x_9_);
            v___x_11_ = lean_apply_2(v_putStr_10_, v_s_7_, lean_box(0));
            return v___x_11_;
        }
}
LEAN_EXPORT lean_object* l_IO_print___at___00IO_println___at___00main_spec__0_spec__0___boxed(lean_object* v_s_12_, lean_object* v_a_13_){
_start:
{
lean_object* v_res_14_; 
v_res_14_ = l_IO_print___at___00IO_println___at___00main_spec__0_spec__0(v_s_12_);
return v_res_14_;
}
}
LEAN_EXPORT lean_object* l_IO_println___at___00main_spec__0(lean_object* v_s_15_){
_start:
{
uint32_t v___x_17_; lean_object* v___x_18_; lean_object* v___x_19_; 
v___x_17_ = 10;
v___x_18_ = lean_string_push(v_s_15_, v___x_17_);
v___x_19_ = l_IO_print___at___00IO_println___at___00main_spec__0_spec__0(v___x_18_);
return v___x_19_;
}
}
LEAN_EXPORT lean_object* l_IO_println___at___00main_spec__0___boxed(lean_object* v_s_20_, lean_object* v_a_21_){
_start:
{
lean_object* v_res_22_; 
v_res_22_ = l_IO_println___at___00main_spec__0(v_s_20_);
return v_res_22_;
}
}
static lean_object* _init_l_main___closed__1(void){
_start:
{
lean_object* v___x_24_; lean_object* v___x_25_; lean_object* v___x_26_; 
v___x_24_ = lean_unsigned_to_nat(105u);
v___x_25_ = lean_unsigned_to_nat(252u);
v___x_26_ = lean_myGcd(v___x_25_, v___x_24_);
return v___x_26_;
}
}
static lean_object* _init_l_main___closed__2(void){
_start:
{
lean_object* v___x_27_; lean_object* v___x_28_; 
v___x_27_ = lean_obj_once(&l_main___closed__1, &l_main___closed__1_once, _init_l_main___closed__1);
v___x_28_ = l_Nat_reprFast(v___x_27_);
return v___x_28_;
}
}
static lean_object* _init_l_main___closed__3(void){
_start:
{
lean_object* v___x_29_; lean_object* v___x_30_; lean_object* v___x_31_; 
v___x_29_ = lean_obj_once(&l_main___closed__2, &l_main___closed__2_once, _init_l_main___closed__2);
v___x_30_ = ((lean_object*)(l_main___closed__0));
v___x_31_ = lean_string_append(v___x_30_, v___x_29_);
return v___x_31_;
}
}
static lean_object* _init_l_main___closed__5(void){
_start:
{
lean_object* v___x_33_; lean_object* v___x_34_; lean_object* v___x_35_; 
v___x_33_ = lean_unsigned_to_nat(462u);
v___x_34_ = lean_unsigned_to_nat(1071u);
v___x_35_ = lean_myGcd(v___x_34_, v___x_33_);
return v___x_35_;
}
}
static lean_object* _init_l_main___closed__6(void){
_start:
{
lean_object* v___x_36_; lean_object* v___x_37_; 
v___x_36_ = lean_obj_once(&l_main___closed__5, &l_main___closed__5_once, _init_l_main___closed__5);
v___x_37_ = l_Nat_reprFast(v___x_36_);
return v___x_37_;
}
}
static lean_object* _init_l_main___closed__7(void){
_start:
{
lean_object* v___x_38_; lean_object* v___x_39_; lean_object* v___x_40_; 
v___x_38_ = lean_obj_once(&l_main___closed__6, &l_main___closed__6_once, _init_l_main___closed__6);
v___x_39_ = ((lean_object*)(l_main___closed__4));
v___x_40_ = lean_string_append(v___x_39_, v___x_38_);
return v___x_40_;
}
}
LEAN_EXPORT lean_object* _lean_main(){
_start:
{
lean_object* v___x_42_; lean_object* v___x_43_; 
v___x_42_ = lean_obj_once(&l_main___closed__3, &l_main___closed__3_once, _init_l_main___closed__3);
v___x_43_ = l_IO_println___at___00main_spec__0(v___x_42_);
if (lean_obj_tag(v___x_43_) == 0)
{
lean_object* v___x_44_; lean_object* v___x_45_; 
lean_dec_ref_known(v___x_43_, 1);
v___x_44_ = lean_obj_once(&l_main___closed__7, &l_main___closed__7_once, _init_l_main___closed__7);
v___x_45_ = l_IO_println___at___00main_spec__0(v___x_44_);
return v___x_45_;
}
else
{
return v___x_43_;
}
}
}
LEAN_EXPORT lean_object* l_main___boxed(lean_object* v_a_46_){
_start:
{
lean_object* v_res_47_; 
v_res_47_ = _lean_main();
return v_res_47_;
}
}
lean_object* initialize_Init(uint8_t builtin);
lean_object* initialize_Init(uint8_t builtin);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_Gcd(uint8_t builtin) {
lean_object * res;
if (_G_initialized) return lean_io_result_mk_ok(lean_box(0));
_G_initialized = true;
res = initialize_Init(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_Init(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
return lean_io_result_mk_ok(lean_box(0));
}
char ** lean_setup_args(int argc, char ** argv);
void lean_initialize_runtime_module();
#if defined(WIN32) || defined(_WIN32)
#include <windows.h>
#endif
lean_object* run_main(int argc, char ** argv) {
    return _lean_main();
}
int main(int argc, char ** argv) {
#if defined(WIN32) || defined(_WIN32)
  SetErrorMode(SEM_FAILCRITICALERRORS);
  SetConsoleOutputCP(CP_UTF8);
#endif
  lean_object* res;
  argv = lean_setup_args(argc, argv);
  lean_initialize_runtime_module();
  res = initialize_Gcd(1 /* builtin */);
  lean_io_mark_end_initialization();
  if (lean_io_result_is_ok(res)) {
    lean_dec_ref(res);
    lean_init_task_manager();
    res = lean_run_main(&run_main, argc, argv);
  }
  lean_finalize_task_manager();
  if (lean_io_result_is_ok(res)) {
    int ret = 0;
    lean_dec_ref(res);
    return ret;
  } else {
    lean_io_result_show_error(res);
    lean_dec_ref(res);
    return 1;
  }
}
#ifdef __cplusplus
}
#endif
