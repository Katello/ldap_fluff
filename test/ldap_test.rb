require_relative './lib/ldap_test_helper'

class TestLDAP < MiniTest::Test
  include LdapTestHelper

  def setup
    config
    @ldap  = MiniTest::Mock.new
    @fluff = LdapFluff.new(config_hash)
  end

  def test_bind
    @ldap.expect(:bind?, true, ['john', 'password'])
    @fluff.ldap = @ldap
    assert_equal @fluff.authenticate?("john", "password"), true
    @ldap.verify
  end

  def test_groups
    @ldap.expect(:groups_for_uid, ['bros'], ['john'])
    @fluff.ldap = @ldap
    assert_equal @fluff.group_list('john'), ['bros']
    @ldap.verify
  end

  def test_group_membership
    @ldap.expect(:is_in_groups, false, ['john', ['broskies', 'girlfriends'], true])
    @fluff.ldap = @ldap
    assert_equal @fluff.is_in_groups?('john', ['broskies', 'girlfriends']), false
    @ldap.verify
  end

  def test_valid_user
    @ldap.expect(:user_exists?, true, ['john'])
    @fluff.ldap = @ldap
    assert @fluff.valid_user? 'john'
    @ldap.verify
  end

  def test_valid_group
    @ldap.expect(:group_exists?, true, ['broskies'])
    @fluff.ldap = @ldap
    assert @fluff.valid_group? 'broskies'
    @ldap.verify
  end

  def test_invalid_group
    @ldap.expect(:group_exists?, false, ['broskerinos'])
    @fluff.ldap = @ldap
    assert !@fluff.valid_group?('broskerinos')
    @ldap.verify
  end

  def test_invalid_user
    @ldap.expect(:user_exists?, false, ['johnny rotten'])
    @fluff.ldap = @ldap
    assert !@fluff.valid_user?('johnny rotten')
    @ldap.verify
  end
end


