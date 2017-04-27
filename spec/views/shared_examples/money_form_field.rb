RSpec.shared_examples 'money form field' do
  it 'has max length' do
    render
    expect(field[:maxlength]).to eq('255')
  end

  it 'has money pattern' do
    render
    expect(field[:pattern]).to eq('^[0-9.,]+$')
  end
end
