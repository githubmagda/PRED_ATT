function A
f=figure;
p=uicontrol('Parent',f,'Style','pushbutton','Callback',{@C},'Position',[50 50 100 100]);
B(f);
end
function B(f)
e=uicontrol('Parent',f,'Style','edit','String','0');
while(ishandle(f))
    e.String=num2str(randn);
    pause(0.3);
    drawnow();
end
end
function C(~,~)
delete(gcbf);
end